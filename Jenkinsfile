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
                    sh '''
                        if [ -f ./vendor/bin/phpunit ]; then
                          ./vendor/bin/phpunit --coverage-clover=coverage.xml
                        else
                          echo "PHPUnit non installé"
                        fi
                    '''
                }
            }
        }

        stage('Quality Checks') {
            steps {
                container('php-cli') {
                    sh '''
                        echo "==> PHPStan"
                        ./vendor/bin/phpstan analyse src || true

                        echo "==> Rector"
                        ./vendor/bin/rector process --dry-run || true

                        echo "==> Psalm"
                        ./vendor/bin/psalm || true

                        echo "==> PHPCS"
                        ./vendor/bin/phpcs --standard=PSR12 src || true

                        echo "==> PHP-CS-Fixer"
                        ./vendor/bin/php-cs-fixer fix --dry-run --diff || true

                        echo "==> PHPMD"
                        ./vendor/bin/phpmd src text cleancode,codesize,controversial,design,naming,unusedcode || true

                        echo "==> PHPCPD"
                        ./vendor/bin/phpcpd src || true
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
