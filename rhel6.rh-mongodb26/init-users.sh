# mongo_create_users creates the MongoDB admin user and the database user
# configured by MONGO_USERNAME
function mongo_create_users() {
    if [ -z "${MONGODB_ADMIN_PASSWORD}" ]; then
            echo "=> MONGODB_ADMIN_PASSWORD is not set. Authentication can not be set up."
            exit 1
    fi

    # Set admin password
    #echo "=> Creating MongoDB admin user with password: ${MONGODB_ADMIN_PASSWORD}"
    set +e
    mongo admin --eval "db.addUser({user: 'admin', pwd: '${MONGODB_ADMIN_PASSWORD}', roles: ['dbAdminAnyDatabase', 'userAdminAnyDatabase' , 'readWriteAnyDatabase','clusterAdmin' ]});"
    result=$?
    set -e

    if [ $result -ne 0 ]; then
        echo "=> Failed to create MongoDB admin user."
        exit 1
    fi

    # Create user for database
    if [ -n "${MONGODB_USER}" -o -n "${MONGODB_PASSWORD}"]; then
        
        if [ -z "${MONGODB_USER}" ]; then
            echo "=> MONGODB_USER is not set. Failed to create MongoDB user: ${MONGODB_USER}"
            exit 1
        fi
        if [ -z "${MONGODB_PASSWORD}" ]; then
            echo "=> MONGODB_PASSWORD is not set. Failed to create MongoDB user: ${MONGODB_USER}"
            exit 1
        fi
	if [ -z "${MONGODB_DATABASE}" ]; then
            echo "=> MONGODB_DATABASE is not set. Failed to create MongoDB user: ${MONGODB_USER}"
            exit 1
        fi
        #echo "=> Creating a ${MONGODB_USER} user in MongoDB with password: ${MONGODB_PASSWORD}"
        set +e
        mongo ${MONGODB_DATABASE} --eval "db.addUser({user: '${MONGODB_USER}', pwd: '${MONGODB_PASSWORD}', roles: [ 'readWrite' ]});"
        result=$?
        set -e

        if [ $result -ne 0 ]; then
            echo "=> Failed to create MongoDB user: ${MONGODB_USER}"
            return
        fi
    fi
}

if [ -n "${MONGODB_USER}" -o -n "${MONGODB_PASSWORD}" -o -n "${MONGODB_ADMIN_PASSWORD}" ]; then
    mongo_create_users

    # Enable auth
    mongo_common_args+="--auth "
fi
