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
                    sh ' composer install '
                }
            }
        }
        stage('Patch Config Path') {
    steps {
        script {
            sh '''
                # Modifier la ligne dans bootstrap.php pour pointer vers Config.php
                sed -i "s|include __DIR__ . '/../src/config.php';|include __DIR__ . '/../src/library/FOSSBilling/Config.php';|" tests-legacy/bootstrap.php
            '''
        }
    }
}

 
        stage('Run Unit Tests ') {
            steps {
                container('php-cli') {
                    sh ' phpunit --coverage-text'
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
