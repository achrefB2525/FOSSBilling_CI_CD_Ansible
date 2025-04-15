pipeline {
    agent { label 'php-agent'}

    stages {
        stage('Clone Repository') {
            steps {
                git url: 'https://github.com/FOSSBilling/FOSSBilling.git', branch: 'main'
            }
        }

        stage('Install Dependencies') {
            steps {
                 container('php-cli'){
                sh 'composer install --no-interaction --ignore-platform-req=ext-intl '
                 }
            }
        }

        stage('Run Tests') {
            steps {
              
                sh './vendor/bin/phpunit || true'
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
