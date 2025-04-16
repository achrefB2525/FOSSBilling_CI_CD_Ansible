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
                    sh 'phpunit --coverage-text'
                }
            }
        }

        stage('Quality Checks') {
            steps {
                echo 'Running quality checks...'
                container('php-cli') {
                    sh '''
                        echo "==> PHPStan"
                        phpstan analyse src || true

                        echo "==> Rector"
                        rector process --dry-run || true

                        echo "==> Psalm"
                        psalm || true

                        echo "==> PHPCS"
                        phpcs --standard=PSR12 src || true

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

        stage('Analyse SonarQube') {
            agent {
                label 'sonar-agent'
            }
            steps {
                withSonarQubeEnv('sonarqube') {
                    container('sonar-cli') {
                        sh '''
                            sonar-scanner \
                                -Dsonar.projectKey=my-php-project \
                                -Dsonar.sources=. \
                                -Dsonar.host.url=$SONAR_HOST_URL \
                                -Dsonar.login=$SONAR_AUTH_TOKEN
                        '''
                    }
                }
            }
        }
    }
}
