pipeline {
    agent { label 'php-agent' }

    stages {
        stage('Clone Repository') {
            steps {
                git url: 'https://github.com/FOSSBilling/FOSSBilling.git', branch: 'main'
            }
        }

        stage('Install Dependencies') {
            steps {
                container('php-cli') {
                    sh 'composer install --no-interaction --ignore-platform-req=ext-intl'
                }
            }
        }

        stage('Run Unit Tests') {
            steps {
                container('php-cli') {
                    sh 'simple-phpunit --coverage-text'  // Utilisation directe de simple-phpunit
                }
            }
        }

        stage('Quality Checks') {
            steps {
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

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonarqube') {
                    sh '''
                        sonar-scanner \
                          -Dsonar.projectKey=FOSSBilling \
                          -Dsonar.sources=. \
                          -Dsonar.language=php \
                          -Dsonar.php.coverage.reportPaths=coverage.xml
                    '''
                }
            }
        }
    }
}
