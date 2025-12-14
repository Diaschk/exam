pipeline {
    agent any  
    
    tools {
        python 'Python-3.11'
    }
    
    environment {
        DOCKER_IMAGE = 'diaschk/my-python-app'
        DOCKER_TAG = "${env.BUILD_ID}"
        DOCKER_REGISTRY = 'https://index.docker.io/v1/'
    }

    triggers {
        pollSCM('H/2 * * * *')
    }

    stages {
        stage('Cleanup Workspace') {
            steps {
                cleanWs()
            }
        }

        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/Diaschk/exam.git'
            }
        }

        stage('Setup Environment') {
            steps {
                sh 'python -m venv venv'
                sh './venv/bin/pip install --upgrade pip'
                sh './venv/bin/pip install -r requirements.txt'
            }
        }

        stage('Test') {
            steps {
                sh './venv/bin/pytest --junitxml=reports/results.xml'
                junit 'reports/results.xml'
            }
        }

        stage('Package') {
            steps {
                sh 'python setup.py sdist bdist_wheel || true'
                archiveArtifacts artifacts: 'dist/*'
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    dockerImage = docker.build("${DOCKER_IMAGE}:${DOCKER_TAG}")
                }
            }
        }
        
        stage('Push to Docker Hub') {
            steps {
                script {
                    docker.withRegistry(DOCKER_REGISTRY, 'docker-hub-token') {
                        dockerImage.push()  
                        dockerImage.push('latest')  
                    }
                }
            }
        }
        
        stage('Cleanup Local Images') {
            steps {
                script {
                    sh "docker rmi ${DOCKER_IMAGE}:${DOCKER_TAG} || true"
                    sh "docker rmi ${DOCKER_IMAGE}:latest || true"
                    sh 'docker image prune -f'
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
        success {
            echo "Pipeline успішно запущено"
            echo "Образ доступний в Docker Hub: ${DOCKER_IMAGE}:${DOCKER_TAG}"
        }
        failure {
            echo "Pipeline не запущено"
        }
    }
}