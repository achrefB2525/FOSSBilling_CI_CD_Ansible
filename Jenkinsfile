pipeline {
    agent { label 'php-agent' }

    stages {
        stage('Clone Repository') {
            steps {
                echo 'Cloning the repository...'
                git url: 'https://github.com/FOSSBilling/FOSSBilling.git', branch: 'main'
            }
        }

        stage('Install Dependencies') {
            steps {
                echo 'Installing dependencies using Composer...'
                container('php-cli') {
                    sh 'composer install'
                }
            }
        }

        stage('Prepare Config') {
            steps {
                echo 'Copying sample config to config.php...'
                sh 'cp src/config-sample.php src/config.php'
            }
        }

        stage('Run Unit Tests') {
            steps {
                echo 'Running PHPUnit tests...'
                container('php-cli') {
                    sh 'XDEBUG_MODE=coverage phpunit --coverage-clover=coverage.xml'
                }
            }
        }

        stage('Quality Checks') {
            steps {
                echo 'Running quality checks...'
                container('php-cli') {
                    sh '''
                        echo "==> PHPStan"
                        phpstan analyse --error-format=checkstyle > phpstan-report.xml || true

                        echo "==> Rector"
                        rector process --dry-run || true

                        echo "==> Psalm"
                        psalm --output-format=xml > psalm-report.xml || true

                        echo "==> PHPCS"
                        phpcs --standard=PSR12 --report-file=phpcs-report.xml || true

                        echo "==> PHP-CS-Fixer"
                        php-cs-fixer fix --dry-run --diff || true

                        echo "==> PHPMD"
                        phpmd src text cleancode,codesize,controversial,design,naming,unusedcode || true

                        echo "==> PHPCPD"
                        phpcpd src || true
                    '''
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonarqube') {
                    container('php-cli') {
                        script {
                            sh '''
                                /opt/sonar-scanner/bin/sonar-scanner  \
                                    -Dsonar.projectKey=my-php-project \
                                    -Dsonar.sources=. \
                                    -Dsonar.host.url=$SONAR_HOST_URL \
                                    -Dsonar.login=$SONAR_AUTH_TOKEN \
                                    -Dsonar.phpstan.reportPath=phpstan-report.xml \
                                    -Dsonar.phpcs.reportPath=phpcs-report.xml \
                                    -Dsonar.php.coverage.reportPaths=coverage.xml \
                                    -Dsonar.psalm.reportPath=psalm-report.xml
                            '''
                        }
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                container('php-cli') {
                    script {
                        sh 'docker build -t fossbilling1/fossbilling:v1 .'
                    }
                }
            }
        }

        stage('Scan Image with Trivy') {
            steps {
                container('php-cli') {
                    script {
                        sh 'trivy image fossbilling1/fossbilling:v1'
                    }
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                container('php-cli') {
                    script {
                        def dockerHubImageName = "fossbilling1/fossbilling:v1"
                        withCredentials([string(credentialsId: 'dockerhub', variable: 'dockerhub')]) {
                            sh "docker login -u fossbilling1 -p ${dockerhub}"
                            sh "docker push ${dockerHubImageName}"
                        }
                    }
                }
            }
        }

        stage('Déploiement avec kubectl') {
  steps {
        container('php-cli') { 
                sh '''
                curl -L -o output.yaml https://raw.githubusercontent.com/achrefB2525/FOSSBilling_CI_CD_Ansible/main/output.yaml

                kubectl apply -f output.yaml
            '''

        }
    }

    }
        }
    }

