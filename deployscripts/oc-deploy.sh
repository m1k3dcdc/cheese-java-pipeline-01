#source ./setenv.sh
# ##### Variable section - START
SCRIPT=oc-deploy.sh
OPENSHIFT_PROJECT=mavc23-dev
GITHUB_SECRET=$2
# ##### Variable section - END   

# ***** Function section - START
deploy()
{
    #oc new-project $OPENSHIFT_PROJECT
    oc project $OPENSHIFT_PROJECT
    BASE_DOMAIN=$(oc get DNS cluster -o jsonpath='{.spec.baseDomain}')
    echo OpenShift cluster domain is ${grn}$BASE_DOMAIN${end}

    oc new-app -f $PWD/deployscripts/cheese-java-pipeline-template.yaml -p OPENSHIFT_PROJECT=$OPENSHIFT_PROJECT
    #oc patch svc OPENSHIFT_APP_LABEL --type=json -p '[{"op": "replace", "path": "/spec/ports/0/targetPort", "value":8082}]'    -p OPENSHIFT_CLUSTER_DOMAIN=$BASE_DOMAIN -p OPENSHIFT_GITHUB_SECRET=$GITHUB_SECRET
    ROUTE_URL=$(oc get route windfire-restaurants-backend -o jsonpath='{.spec.host}')
    echo Test it at ${grn}$ROUTE_URL${end}
}


inputParameters()
{
    ###### Input OpenShift Project
    if [ "$OPENSHIFT_PROJECT" != "" ]; then
        echo OpenShift project is set to $OPENSHIFT_PROJECT
    else
        echo ${grn}Enter OpenShift project - leaving blank will set project to ${end}${mag}cheese : ${end}
        read OPENSHIFT_PROJECT
        if [ "$OPENSHIFT_PROJECT" == "" ]; then
            OPENSHIFT_PROJECT=cheese
        fi
    fi
    ###### Input GitHub Secret
    if [ "$GITHUB_SECRET" != "" ]; then
        echo GitHub Secret is set to $GITHUB_SECRET
    else
        echo ${grn}Enter Secret Name for GitHub - leaving blank will set secret name to ${end}${mag}m1k3dcdc-github : ${end}
        read GITHUB_SECRET
        if [ "$GITHUB_SECRET" == "" ]; then
            GITHUB_SECRET=m1k3dcdc-github
        fi
    fi
    deploy
}
# ***** Function section - END

# ##############################################
# #################### MAIN ####################
# ##############################################
inputParameters