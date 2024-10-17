set -e
set -x pipefail

python3 -m venv $WORKSPACE/environments/django-test

source $WORKSPACE/environments/django-test/bin/activate

export DJANGO_TEST_APPS="absolute_url_overrides admin_autodiscover admin_checks admin_default_site admin_registration admin_scripts app_loading apps asgi async.test_async_model_methods async.tests bash_completion builtin_server cache check_framework conditional_processing constraints context_processors csrf_tests custom_lookups custom_methods datatypes db_typecasts db_utils dbshell.test_postgresql decorators deprecation dispatch empty empty_models field_deconstruction field_defaults field_subclassing file_storage files fixtures_model_package from_db_value handlers httpwrappers humanize_tests i18n invalid_models_tests logging_tests m2o_recursive mail max_lengths messages_tests middleware middleware_exceptions migrate_signals migrations migration_test_data_persistence migrations2 model_enums model_indexes model_meta model_utils no_models or_lookups pagination project_template properties requests reserved_names resolve_url responses save_delete_hooks schema servers sessions_tests settings_tests shell shortcuts signed_cookies_tests signing sitemaps_tests sites_tests staticfiles_tests str template_backends template_loader test_client test_client_regress test_exceptions test_runner transaction_hooks transactions urlpatterns urlpatterns_reverse user_commands utils_tests validators version wsgi"

# Disable buffering, so that the logs stream through.
export PYTHONUNBUFFERED=1

#Get YugabyteDB version and set it as environment variable

output=$($YUGABYTE_HOME_DIRECTORY/bin/ysqlsh -c "SELECT version();")
version=$(echo "$output" | sed -n 's/^.*PostgreSQL [^ ]*-YB-\([^ ]*\).*$/\1/p')
export YB_VERSION=$version

export DJANGO_TESTS_DIR="django_tests_dir"
mkdir -p $DJANGO_TESTS_DIR

git clone git@github.com:yugabyte/yb-django.git --branch alter-update

cd yb-django

pip3 install -r requirements.txt
pip3 install -e .
cd ..

git clone https://github.com/django/django.git --branch $DJANGO_BRANCH $DJANGO_TESTS_DIR/django


cd $DJANGO_TESTS_DIR/django 
pip3 install -e . 
pip3 install -r tests/requirements/py3.txt; cd ../../

create_settings() {
    cat << ! > "test_yugabyte.py"
DATABASES = {
   'default': {
       'ENGINE': 'django_yugabytedb',                                                                          
       'NAME': 'yugabyte',                                                                              
       'HOST': 'localhost',                                                                             
       'PORT': 5433,                                                                                    
       'USER': 'yugabyte'
   },
   'other': {
       'ENGINE': 'django_yugabytedb',                                                                            
       'NAME': 'other',                                                                                
       'HOST': 'localhost',                                                                               
       'PORT': 5433,                                                                                      
       'USER': 'yugabyte' 
   },
}
SECRET_KEY = 'django_tests_secret_key'
PASSWORD_HASHERS = [
    'django.contrib.auth.hashers.MD5PasswordHasher',
]
DEFAULT_AUTO_FIELD = 'django.db.models.AutoField'

USE_TZ = False
!
}

cd $DJANGO_TESTS_DIR/django/tests
create_settings

EXIT_STATUS=0
for DJANGO_TEST_APP in $DJANGO_TEST_APPS
do
   echo "==========================================================================================="
   echo $DJANGO_TEST_APP
   echo "==========================================================================================="
   python3 runtests.py --settings=test_yugabyte -v 3 $DJANGO_TEST_APP --noinput || EXIT_STATUS=$?
done

deactivate

exit $EXIT_STATUS