# OES Data Explorer

A simple interface for accessing US wage data in the BLS OES data set through the Department of Labor API

## Overview

The app has two main substantive pieces: (1) the main logic to call the DOL API (/controllers/application.rb); and, (2) a script to populate the local database tables with the data necessary to allow a user to select the correct parameters (doldownload.rake). The data for (2) is provided already with this source for the 2011 OES in the /datadumps folder.

The live deploy can be found at http://www.oesdataexplorer.com

This is free software under the MIT license.

I welcome suggestions, comments, and code contributions on GitHub:
https://github.com/daguar/oes-data-explorer

Or, shoot me an e-mail at:
dave /at/ datawonk /dot/ net


## Installation

The app was built on Ruby 1.9.3 and Rails 3.2.2, and so I recommend using RVM to run it in this environment.

To set up a local install after downloading the source:

(1) Register with the Department of Labor API:
https://devtools.dol.gov/developer/Account/Register

(2) Log in at https://devtools.dol.gov/developer and click "My Tokens", then "Create New Token", then put in some info, keeping note of your "shared secret".

(3) In /config, rename EXAMPLE_application.yml to application.yml, and set "dol_key" to your token value, and dol_secret to your shared secret. (Note: ga_tracking is the tracking ID for Google Analytics, and probably unnecessary for you.)

(4) Then, just run the following commands at a terminal from the application root:

Install dependencies
```ruby
bundle install
```

Create local database tables
```ruby
rake db:migrate
```

Load search parameter data from the provided CSV files in /datadumps
```ruby
rake loaddata:all
```

