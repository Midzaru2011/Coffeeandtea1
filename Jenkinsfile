pipeline {
    agent any

    environment {
        DOCKER_HUB_CREDENTIALS = credentials('docker-hub-creds') // Учетные данные Docker Hub
        IMAGE_NAME = 'midzaru2011/coffeeandtea'     // Имя образа в Docker Hub
        IMAGE_TAG = "v${BUILD_NUMBER}"                          // Тег образа
        GITHUB_CREDENTIALS = 'github-credentials'
    }

    tools {
        maven 'Maven-3.9.9' // Указываете имя конфигурации Maven из Global Tool Configuration
    }

    stages {

        stage('Delete workspace') {
            steps {
                echo 'Deleting workspace'
                deleteDir()
            }
        }
        
        stage('Checkout') {
            steps {
                git branch: 'master',
                credentialsId: env.GITHUB_CREDENTIALS,
                url: 'https://github.com/Midzaru2011/CoffeeAndTea.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${IMAGE_NAME}:${IMAGE_TAG}")
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    docker.withRegistry('https://registry.hub.docker.com', 'docker-hub-creds') {
                        docker.image("${IMAGE_NAME}:${IMAGE_TAG}").push()
                    }
                }
            }
        }
        
    }

    post {
        always {
            cleanWs() // Очищает workspace
        }
    }
}