# How to run

Here is a high-level overview of how to run Cloud Console app either locally
or via Google App Engine:

1. Install `gcloud` and enable `gcloud preview app`
1. Download credentials
1. Install dependencies
1. Run the app locally, or (optionally) publish it to Google App Engine

Below are the details for each of the steps.

## Install `gcloud`

To get `gcloud`, install the [Google Cloud SDK](https://cloud.google.com/sdk).

Then, to use the [`gcloud preview app` component](https://cloud.google.com/sdk/gcloud-app)
to manage Google App Engine applications, run:

```bash
gcloud components update app
```

## Download API credentials

1. Visit the [Google Cloud Console](https://console.cloud.google.com)

1. Select a project

1. Ensure you have billing set up in this project.
   [Free trial](https://cloud.google.com/free-trial/) is OK, too.

1. In the menu on the left, navigate to: APIs & auth -> APIs

1. Enable the Google Compute Engine API.

1. Navigate to: APIs & auth -> Credentials

1. Click on "Add credentials"

1. Select "OAuth 2.0 client ID"

1. Select "Web application"

   1. **Name:** this will be displayed to your users on the OAuth
      permissions screen.

      For example, you can use: `My Cloud Console`

   1. **Authorized Javascript origins:** this is a list of URLs which are
      allowed to use these credentials. For testing locally, you need to have at
      least `http://localhost:8080` (assuming your local App Engine development
      server will run on the default port of `8080`). If you plan to publish to
      your Google App Engine app, you need to list it here as well,
      comma-separated.

      For example, for local-only testing, you can use:
      `http://localhost:8080`

      For publishing to Google App Engine, you can use:
      `https://<my-app-name>.appspot.com`

      Be sure to substitute the real name of your app for `my-app-name`.

      Enter these URLs in separate text boxes.

      > _Note:_ if you want to deploy to a version which is not the default,
      > which is highly recommended when testing or deploying new versions, you
      > will need to add the other version(s) as well. The URL format for
      > non-default versions is:
      > `https://<version>-dot-<app>.appspot.com`
      > since this application only has a single (`default`) module. For more
      > info, see [documentation on routing](https://cloud.google.com/appengine/docs/python/modules/routing).

   1. **Authorized redirect URIs:** these are the URLs that Google will redirect
      the user to after the user provides consent via the OAuth2 authorization
      flow.

      > _Note:_ since we are using the
      > [`oauth2client`](https://github.com/google/oauth2client) library, the
      > default is `/oauth2callback` which can be seen as the default value for
      > the parameter `callback_path` in the
      > [`oauth2client.appengine.OAuth2Decorator`](https://github.com/google/oauth2client/blob/master/oauth2client/appengine.py)
      > constructor. This can be changed in [`console.py`](console.py) by adding
      > `callback_path` as a keyword argument to the
      > `OAuth2DecoratorFromClientSecrets` constructor, which is a subclass of
      > `OAuth2Decorator`.

      Thus, for local-only testing, you can use:
      `http://localhost:8080/oauth2callback`

      For publishing to Google App Engine, you can use:
      `https://<my-app-name>.appspot.com/oauth2callback`

      See the note in the previous bullet about non-default versions, as it
      applies here as well.

      Enter these URLs in separate text boxes.

1. Click on "Create"

1. You will see a dialog box pop up and show you your client ID and client
   secret strings. Press "OK" to dismiss this dialog box, as we won't use those
   strings as-is.

1. Find your newly-created client ID in the list by name.

1. Click the download icon (down arrow with a horizontal line) at the right side
   of the page.

1. Save this file as `client_secrets.json` in this directory.

## Install dependencies

1. Ensure you have `pip` installed.

  Per the [pip docs](https://pip.pypa.io/en/stable/installing.html):

  > Note that Python 2.7.9 and later (on the python2 series), and Python 3.4 and
  > later include pip by default, so you may have pip already.

  If you don't have it installed, here's how to install it:

  * on Debian, Ubuntu, and derivatives:

    ```bash
    sudo apt-get install python-pip
    ```

  * on Red Hat, CentOS, Fedora, and derivatives:

    ```bash
    sudo yum install python-pip
    ```

  * on OS X:

    ```bash
    sudo easy_install pip
    ```

  For all other systems, see [pip docs](https://pip.pypa.io/en/stable/installing.html).

1. Install dependencies specified in `requirements.txt` via `pip`:

  ```bash
  make pip-install
  ```

  These libraries will be installed in `third_party/python` and are visible to
  the app via [`appengine_config.py`](appengine_config.py).

1. Running tests

  First, install the testing dependencies:

  ```bash
  make pip-install-test
  ```

  Then, run the tests via:

  ```bash
  make test
  ```

## Run the app locally or publish to Google App Engine

1. Run the app with a local development server:

  ```bash
  make local
  ```

  You can access the app via [http://localhost:8080/](http://localhost:8080/).

1. (optional) Deploy the app to Google App Engine:

  ```bash
  # Note: your Google Cloud Platform project is also your Google App Engine app
  # name.
  make PROJECT=<my-project> VERSION=<my-version> deploy
  ```

  > _Note:_ if you want to test with a version that's not the default, see the
  > note above in _Authorized Javascript origins,_ which also applies to
  > _Authorized redirect URIs_. The version-specific URI needs to be
  > included in your JSON credentials to allow testing with that version.

  You can access the app via `https://<my-project>.appspot.com` for a default
  version. For non-default versions, see the note referenced above.
