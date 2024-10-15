pipeline {
    agent any
    
    environment {
        NETLIFY_SITE_ID = '36144c89-7e2f-4fd5-bc2e-9b34b30a22f3'
        NETLIFY_AUTH_TOKEN = credentials('netlify-token')
		REACT_APP_VERSION = '1.2.3'
    }

    stages {                
        stage('Build') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps {
                withEnv(['NODE_OPTIONS=--openssl-legacy-provider']) {
                    sh '''
                        ls -la
                        node --version
                        npm --version
                        cleanWs()
                        npm ci
                        npm run build
                        ls -la
                    '''
                }
            }
        } 

        stage('Test Praveen1') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    test -f build/index.html
                    npm test
                '''
            }
        }   

        stage('E2E') {
            agent {
                docker {
                    image 'mcr.microsoft.com/playwright:v1.39.0-jammy'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    # Use a writable directory for npm global installs
                    export HOME=/tmp/jenkins
                    mkdir -p $HOME/.npm-global
                    # Set npm to use this directory for global installs
                    npm config set prefix="$HOME/.npm-global"
                    # Update the PATH to include the new directory
                    export PATH=$HOME/.npm-global/bin:$PATH
                    # Debugging: Print HOME and current user
                    echo "HOME: $HOME"
                    echo "Current User: $(whoami)"
                    # Install serve globally
                    npm install -g serve
                    # Serve the build and run tests
                    nohup serve -s build &
                    sleep 10
                    # Run Playwright tests
                    npx playwright test --reporter=html
                '''
            }
        }   
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
                    # Use a writable directory for npm global installs and cache
                    echo "Small change to trigger the CI/CD Jenkins Pipeline"
                    export HOME=/tmp/jenkins
                    mkdir -p $HOME/.npm-global
                    mkdir -p $HOME/.npm-cache
                    # Set npm to use this directory for global installs and cache
                    npm config set prefix="$HOME/.npm-global"
                    npm config set cache "$HOME/.npm-cache"
                    # Update the PATH to include the new directory
                    export PATH=$HOME/.npm-global/bin:$PATH
                    # Debugging: Print HOME and current user
                    echo "HOME: $HOME"
                    echo "Current User: $(whoami)"
                    # Install netlify-cli globally
                    npm install -g netlify-cli node-jq
                    echo "Now shall wait for some time"
                    sleep 10
                    netlify --version
                    echo 'Deploying to site : $NETLIFY_SITE_ID'
                    netlify status
                    netlify deploy --dir=build --json > deploy-output.json
                    node-jq -r '.deploy_url' deploy-output.json
                '''
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
                    # Use a writable directory for npm global installs and cache
                    echo "Small change to trigger the CI/CD Jenkins Pipeline"
                    export HOME=/tmp/jenkins
                    mkdir -p $HOME/.npm-global
                    mkdir -p $HOME/.npm-cache
                    # Set npm to use this directory for global installs and cache
                    npm config set prefix="$HOME/.npm-global"
                    npm config set cache "$HOME/.npm-cache"
                    # Update the PATH to include the new directory
                    export PATH=$HOME/.npm-global/bin:$PATH
                    # Debugging: Print HOME and current user
                    echo "HOME: $HOME"
                    echo "Current User: $(whoami)"
                    # Install netlify-cli globally
                    npm install -g netlify-cli
                    echo "Now shall wait for some time"
                    sleep 10
                    netlify --version
                    echo 'Deploying to site : $NETLIFY_SITE_ID'
                    netlify status
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
                CI_ENVIRONMENT_URL = 'https://chic-llama-f278dd.netlify.app'
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
