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
                    sh '''
                        composer install 
                        composer require --dev phpunit/phpunit
                    '''
                }
            }
        }

        stage('Run Unit Tests (phpunit.xml.dist)') {
            steps {
                container('php-cli') {
                    def customPath = '/usr/local/bin:$PATH'
                    sh ' phpunit --configuration phpunit.xml.dist --coverage-text'
                }
            }
        }

        stage('Run Unit Tests (phpunit-live.xml)') {
            steps {
                container('php-cli') {
                    def customPath = '/usr/local/bin:$PATH'
                    sh ' phpunit --configuration phpunit-live.xml --coverage-text'
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

        stage('SonarQube Analysis') {
            steps {
                echo 'Starting SonarQube analysis...'
                withSonarQubeEnv('sonarqube') {
                    sh '''
                          sonar \
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
