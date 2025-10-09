#source ../../../setenv.sh

# ##### START - Variable section
RUN_FUNCTION=
# ##### END - Variable section

# ***** START - Function section
createBuildConfig()
{
    #oc new-project $OPENSHIFT_PROJECT
    #oc project $OPENSHIFT_PROJECT
    oc create -f $PWD/deployscripts/BuildConfig.yaml
    oc set triggers bc/cheese-java-pipeline --from-github
}

# ##############################################
# #################### MAIN ####################
# ##############################################
createBuildConfig