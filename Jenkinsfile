pipeline {
    agent any
    
    environment {
        NETLIFY_SITE_ID = '36144c89-7e2f-4fd5-bc2e-9b34b30a22f3'
        NETLIFY_AUTH_TOKEN = credentials('netlify-token')
    }

    stages {                   
        stage('Staging area') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                    args '--user=root'
                }
            }
            steps {
                sh '''
                    # Set up environment for npm global installs
                    export HOME=/tmp/jenkins
                    mkdir -p $HOME/.npm-global
                    mkdir -p $HOME/.npm-cache

                    # Configure npm for global installs and cache
                    npm config set prefix "$HOME/.npm-global"
                    npm config set cache "$HOME/.npm-cache"
                    export PATH=$HOME/.npm-global/bin:$PATH

                    # Debugging info
                    echo "HOME: $HOME"
                    echo "Current User: $(whoami)"
                    echo "PATH: $PATH"

                    # Install netlify-cli and node-jq globally
                    npm install -g netlify-cli node-jq

                    # Ensure node-jq is properly installed
                    echo "Checking if node-jq is installed"
                    which node-jq || echo "node-jq not found"

                    # Deploy to Netlify and capture the deploy URL
                    echo "Deploying to site: $NETLIFY_SITE_ID"
                    netlify deploy --dir=build --json > deploy-output.json

                    # Use the full path to node-jq for extracting deploy_url
                    /tmp/jenkins/.npm-global/bin/node-jq -r '.deploy_url' deploy-output.json
                '''
                script {
                    // Extract deploy_url with full path to node-jq
                    def nodeJqPath = '/tmp/jenkins/.npm-global/bin/node-jq'
                    env.STAGING_URL = sh(script: "${nodeJqPath} -r '.deploy_url' deploy-output.json", returnStdout: true).trim()
                    echo "Staging URL: ${env.STAGING_URL}"
                }			
            }
        } // End of Staging area 

        stage('Approval') {
            steps {
                echo 'Approval'
                input message: 'Ready to deploy', ok: 'Yes, I am sure I want to deploy'
            }
        }

        stage('Deploy Prod') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                    args '--user=root'
                }
            }
            steps {
                sh '''
                    # Set up environment for npm global installs
                    export HOME=/tmp/jenkins
                    mkdir -p $HOME/.npm-global
                    mkdir -p $HOME/.npm-cache

                    # Configure npm for global installs and cache
                    npm config set prefix "$HOME/.npm-global"
                    npm config set cache "$HOME/.npm-cache"
                    export PATH=$HOME/.npm-global/bin:$PATH

                    # Install netlify-cli globally
                    npm install -g netlify-cli
                    netlify --version

                    # Deploy to production site
                    echo 'Deploying to site: $NETLIFY_SITE_ID'
                    netlify deploy --dir=build --prod
                '''
            }
        } //End of Deploy-Prod

        stage('Prod E2E') {
            agent {
                docker {
                    image 'mcr.microsoft.com/playwright:v1.39.0-jammy'
                    reuseNode true
                }
            }

            environment {
                CI_ENVIRONMENT_URL = "${env.STAGING_URL}"
				echo "The CI_ENVRONMENT_URL is: ${CI_ENVIRONMENT_URL}"
            }

            steps {
                sh '''
                    npx playwright test --reporter=html
                '''
            }
        }
    } // Close stages block

    post {
        always {
            junit 'jest-results/junit.xml'
            publishHTML([ 
                allowMissing: false,
                alwaysLinkToLastBuild: false,
                keepAll: false,
                reportDir: 'playwright-report',
                reportFiles: 'index.html',
                reportName: 'Collective HTML Report',
                reportTitles: '',
                useWrapperFileDirectly: true
            ])
        }
    }
}
