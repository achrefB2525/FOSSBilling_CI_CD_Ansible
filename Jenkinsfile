stage('Quality Checks') {
    steps {
        echo 'Running quality checks...'
        container('php-cli') {
            sh '''
                echo "==> PHPStan"
                phpstan analyse --format=xml > phpstan-report.xml || true

                echo "==> Rector"
                rector process --dry-run || true

                echo "==> Psalm"
                psalm --output-format=xml > psalm-report.xml || true

                echo "==> PHPCS"
                phpcs --standard=PSR12 --report=xml > phpcs-report.xml || true

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
            script {
                // Command to run SonarQube analysis
                sh '''
                    sonar-scanner \
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
