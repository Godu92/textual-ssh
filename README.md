# Textual SSH

- [Textual SSH](#con-textual-connection-textual-servers)
  - [TODO](#todo)
  - [About](#about)
    - [Bash](#bash)
      - [Bash - Setup](#bash---setup)
      - [Bash - Usage](#bash---usage)
    - [Python](#python)
      - [Python - Setup](#python---setup)
    - [Alias](#alias)
      - [Alias - Bash - Setup](#alias---bash---setup)
      - [Alias - Python - Setup](#alias---python---setup)

## TODO

- setup the python portion
- maybe also get it setup to use specific password files
  - Consider using environment variables or a secure keyring service like `pass` or `gopass`

## About

This project is an attempt at trying to get a python textual front end connecting to a backend bash script as a way of connecting to various servers using ssh.

### Bash

The bash portion is to do the following:

- The script dynamically constructs the ssh command based on the input parameters and the JSON configuration.
- It retrieves the user, domain, and machine_name from the JSON file.
- The display_help function shows a list of valid machine types and domains in a tabular format using column -t. This makes it easy to understand the available options.
- The `base` script checks if the provided `machine_type` and `domain` exist in the JSON configuration. If not, it displays an error message and the help text.

#### Bash - Setup

- Create a `.json` file to match what your case is (also visible in `example.json`)
  - Example:

    ```json
    {
        "user": "user",
        "domains": {
            "east": "us-east.com",
            "west": "us-west.com"
        },
        "machines": {
            "db1": "test-db1",
            "db2": "test-db2",
            "ui": "test-ui",
            "server": "test-server"
        }
    }
    ```

- Also create a `.env` file that will store your password (if needed)

    ```sh
    PASSWORD=mypassword
    ```

- Adding New Machines/domains:
  - To add new machine types or domains, simply update the machines.json file.
- Support for Different Users:
  - You can extend create new `json` files with different users as needed.

#### Bash - Usage

- Make sure the scripts are executable:

    ```sh
    chmod +x connect_base.sh
    chmod +x connect_plain.sh
    chmod +x connect_pass.sh
    ```

- Run the script with parameters:

    ```sh
    ./connect db east
    ./connect_pass db east
    ```

    This will connect to `ssh user@test-db1.us-east.com` and print the password for manual entry.

- Run the script without parameters to see the help text:

    ```sh
    ./connect
    ./connect_pass
    ```

    This will display a list of available machine types and domains.

### Python

The python portion is a script making use of the `textual` library to make a clickable user interface in the terminal that can be used to select the machine and domain rather than typing.

- would be really neat if it even came with the option to add to the file from the interface
- also would be nice for "one off connections" that allow user input
  - even cooler if it kept a history of these "one offs" in a separate db-esq file

#### Python - Setup

### Alias

Once all of this is setup, it would be good to make aliases that could be used to call these from anywhere

#### Alias - Bash - Setup

Add the following lines into your `.bashrc` (or where ever you prefer to stick your aliases)

```sh
connect=~/git/textual-servers/bash/connect_plain.sh
connect-pass=~/git/textual-servers/bash/connect_pass.sh
```

#### Alias - Python - Setup

Add the following lines into your `.bashrc` (or where ever you prefer to stick your aliases)

```sh
connect=~/git/textual-servers/bash/connect.py
```
