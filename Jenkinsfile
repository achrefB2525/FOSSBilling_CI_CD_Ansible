pipeline {
    agent { label 'php-agent' }

    stages {
stage('Install Helm') {
  steps {
    sh '''
      curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
      chmod 700 get_helm.sh
      ./get_helm.sh
      export PATH=$HOME/.local/bin:$PATH
      helm version
    '''
  }
}

stage('Deploy with Helm') {
  steps {
    sh '''
      export PATH=$HOME/.local/bin:$PATH
      helm upgrade --install fossbilling-release ./chart --namespace fossbilling-namespace \
        --set env.db.MYSQL_ROOT_PASSWORD=monNouveauRootPass \
        --set env.db.MYSQL_DATABASE=maBase \
        --set env.db.MYSQL_USER=monUser \
        --set env.db.MYSQL_PASSWORD=monPass
    '''
  }
}


        stage('Clone Repository') {
            steps {
                echo 'Cloning the repository...'
                git url: 'https://github.com/FOSSBilling/FOSSBilling.git', branch: 'main'
            }
        }
        stage('Récupérer dossier deployment') {
            steps {
                sh '''

                    git init temp-repo
                    cd temp-repo

                    # Ajouter le remote
                    git remote add origin https://github.com/achrefB2525/FOSSBilling_CI_CD_Ansible.git

                    # Activer le mode sparse-checkout
                    git config core.sparseCheckout true

                    # Définir le dossier à récupérer
                    echo "deployment/" >> .git/info/sparse-checkout

                    # Récupérer uniquement le dossier depuis la branche Kubernetes
                    git pull origin Kubernetes

                    # Déplacer le dossier dans le workspace principal
                    mv deployment ../

                    cd ..
                    rm -rf temp-repo
                '''
            }
        }
    
      stage('Déployer avec Helm') {
            steps {
                dir('deployment') {
                    sh """
                    export PATH=$PATH:/usr/local/bin
                    helm upgrade --install fossbilling-release ./chart \
                      --namespace fossbilling-namespace \
                      --set env.db.MYSQL_ROOT_PASSWORD=monNouveauRootPass \
                      --set env.db.MYSQL_DATABASE=maBase \
                      --set env.db.MYSQL_USER=monUser \
                      --set env.db.MYSQL_PASSWORD=monPass
                    """
                }
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
                        sh 'buildah  build  --isolation=chroot -t achrefdoce/fossbilling:v1 .'
                    }
                }
            }
        }

        stage('Scan Image with Trivy') {
            steps {
                container('php-cli') {
                    script {
                        sh 'trivy image --timeout 10m achrefdoce/fossbilling:v1'
                    }
                }
            }
        }

stage('Push to Docker Hub') {
    steps {
        container('php-cli') {
            script {
                withCredentials([string(credentialsId: 'dockerhub', variable: 'DOCKERHUB_TOKEN')]) {
                    sh '''
                        buildah login -u achrefdoce -p "$DOCKERHUB_TOKEN" docker.io
                        buildah push achrefdoce/fossbilling:v1
                    '''
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

