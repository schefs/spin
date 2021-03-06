# Deploying Spinnaker

## Spinnaker in a air gapped environment Guide

How to setup spinnaker in a air-gapped environment guide

You will need:

* Docker installed
* Kubectl installed configured to your k8s cluster of choice (so you can install spinnaker inside)
* privileged access to your kubernetes cluster so you can let spinnaker role your delivery kingdom
* s3 bucket for spinnaker

### Halyard

first save halyard docker image to file so you can use it later on offline

    docker pull gcr.io/spinnaker-marketplace/halyard:1.13.1
    docker save -o ./halyard-1-13-1.tar  gcr.io/spinnaker-marketplace/halyard:1.13.1

## Lets get This party started

### Run Halyard

Start Halyard in a new Docker container.
The following command creates the Halyard Docker container, mounting the Halyard config directory:

    $ mkdir ~/.hal

You also need to completely disable reads from GCS by setting `spinnaker.config.input.gcs.enabled: false` in /opt/spinnaker/config/halyard-local.yml. We will provide this file with docker volume.

#### On Linux machine

    $ docker run -p 8084:8084 -p 9000:9000 \
        --name halyard \
        -v ~/.hal:/home/spinnaker/.hal \
        -v ~/halyard-local.yml:/opt/spinanker/config/halyard-local.yml \
        -v ${HOME}/.kube/config:/home/spinnaker/.kube/config \
        -d \
        gcr.io/spinnaker-marketplace/halyard:1.13.1

#### On Windows machine

    $ docker run -p 8084:8084 -p 9000:9000 \
       --name halyard \
       -v /c/Users/Eyal/.hal/:/home/spinnaker/.hal \
       -v /c/Users/Eyal/halyard-local.yml:/opt/spinanker/config/halyard-local.yml \
       -v /c/Users/Eyal/.kube:/home/spinnaker/.kube \
       -d   gcr.io/spinnaker-marketplace/halyard:1.13.1

#### Connect to the container

    $ docker exec -it halyard bash
    $ source <(hal --print-bash-completion)

#### Set Kubernetes provider v2.0

    $ hal config provider kubernetes enable
    $ export CONTEXT=$(kubectl config current-context)

#### Set service account auth (not mandatory)

Assign spinnaker k8s service account and RBAC roles

    $ kubectl apply -f  /home/spinnaker/.hal/RBAC.yaml

Modify the existing kubectl context adding the new service account token

    $ TOKEN=$(kubectl get secret --context $CONTEXT \
        $(kubectl get serviceaccount spinnaker-service-account \
            --context $CONTEXT \
            -n spinnaker \
            -o jsonpath='{.secrets[0].name}') \
        -n spinnaker \
        -o jsonpath='{.data.token}' | base64 --decode)
    $ kubectl config set-credentials ${CONTEXT}-token-user --token $TOKEN

Switching to the new service account credentials

    $ kubectl config set-context $CONTEXT --user ${CONTEXT}-token-user

#### Create new provider account

    $ export ACCOUNT=schef
    $ hal config provider kubernetes account add $ACCOUNT --provider-version v2 --docker-registries [] --context $CONTEXT --service-account true
    $ hal config features edit --artifacts true

#### Spinnaker set distributed install on k8s

    $ hal config deploy edit --type distributed --account-name $ACCOUNT

#### Set s3 bucket as storage back-end

NOTE: do not supply the value of --secret-access-key on the command line, you will be prompted to enter the value on STDIN once the command has started running

    $ export REGION=us-east-2
    $ export SPIN_S3_BUCKET=my_bucket_uniq_name
    $ export YOUR_SECRET_KEY_ID=bla-bla-bla
    $ hal config storage s3 edit \
        --access-key-id $YOUR_SECRET_KEY_ID \
        --secret-access-key \
        --region ${REGION} \
        --bucket ${SPIN_S3_BUCKET} \
        --endpoint <alternate endpoint for S3-compatible storage>
    $ hal config storage edit --type s3

#### Remote registries

    $ hal config provider docker-registry enable
    $ hal config provider docker-registry account add nexus \
     --address x.x.x.x:xx \
     --insecure-registry true \
     --username admin --password

#### Deploy

    # List Spinnaker Versions
    $ hal version list

    # Configure you desired version
    $ hal config version edit --version local:1.11.8

    # Deploy
    $ hal deploy apply

#### Expose through ingress

After creating the Deck&Gate ingress, make sure to configure them to expect traffic on your ingress url.

    hal config security ui edit \
        --override-base-url http://spinnaker.$DOMAIN

    hal config security api edit \
        --override-base-url http://spinnaker-api.$DOMAIN


#### Connect to Deck

    $ hal deploy connect
    # or
    $ kubectl port-forward -n spinnaker service/spin-deck 9000
    $ kubectl port-forward -n spinnaker service/spin-gate 8084

#### Save necessary things for when you go air gapped

save all docker images of spinnaker:

    $ ./save-images.sh -n spinnaker -p ./

Pull main BOM:

    $ Curl https://storage.googleapis.com/halconfig/bom/<version>.yml
    $ # Example: https://storage.googleapis.com/halconfig/bom/1.11.8.yml

* install svn - `apt-get install subversion`
* Run the script to pull services BOM manifests `./pull_sub_components.sh`
* Make sure you read spinnaker custom bom guide [here](https://www.spinnaker.io/guides/operator/custom-boms), and update services to be searched from local directory and use custom registry.

#### Backup Halyard

Halyard backup config - This includes all secrets you’ve supplied to hal. Keep this safe!

    $ hal backup create

Halyard backup restore on another machine - Halyard will expand & replace the existing ~/.hal directory with the backup.

    $ hal backup restore --backup-path <backup-name>.tar