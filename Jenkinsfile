pipeline {
    agent any
    
    environment {
        NETLIFY_SITE_ID = '36144c89-7e2f-4fd5-bc2e-9b34b30a22f3'
        NETLIFY_AUTH_TOKEN = credentials('netlify-token')
    }

    stages {   
        stage('Deploy Staging') {
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
                    export HOME=/var/lib/jenkins
                    mkdir -p $HOME/.npm-global
                    mkdir -p $HOME/.npm-cache
                    npm config set prefix "$HOME/.npm-global"
                    npm config set cache "$HOME/.npm-cache"
                    export PATH=$HOME/.npm-global/bin:$PATH
                    echo "PATH: $PATH"
                    
                    # Install netlify-cli and node-jq globally
                    npm install -g netlify-cli node-jq

                    # Debug: Verify node-jq installation
                    npm list -g --depth=0
                    which node-jq
                    ls -al $HOME/.npm-global/bin
                    sleep 10

                    # Deploy to Netlify
                    netlify --version
                    echo 'Deploying to site: $NETLIFY_SITE_ID'
                    netlify deploy --dir=build --json > deploy-output.json
                '''
                script {
                    // Use the exact path for node-jq to avoid PATH issues
                    def nodeJqPath = '/var/lib/jenkins/.npm-global/bin/node-jq'
                    echo "Using node-jq from path: ${nodeJqPath}"
                    env.STAGING_URL = sh(script: "${nodeJqPath} -r '.deploy_url' deploy-output.json", returnStdout: true).trim()
                }
                echo "Staging URL: ${env.STAGING_URL}"
            }                    
        }
    }
}
