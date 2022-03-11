# Environment Setup scripts

Shortcuts to setup different development environments.

To make the transition from one machine to another or the setup after formatting, this repository have shell scripts for many different environments that may be needed in a developer day-to-day.

## Limitations

Currently, this repository only has scripts for setting up the environments in a **macOS** system. All scripts were tested on Intel machines and the ones for Node, Python and Gjira were currently also tested on M1 machines.

## Requirements

- [Homebrew](https://brew.sh/)
- macOS 10.15 (Catalina) or newer - or the default terminal set to use [zsh](https://www.zsh.org/)

## Running

To run any setup the steps are basically the same.

- Clone this repository
- In a terminal, go to this repository's `/mac` folder

  ```sh
  $ cd [repository_path]/mac
  ```

- Give the desired setup script the permission to execute

  ```sh
  $ chmod +x ./node-env.sh
  ```

- Run the shell script
  ```sh
  $ ./node-env.sh
  ```

> In the examples the `node-env.sh` was run. You can replace the filename with any of the available files as you need, when running.
>
> So, for both the steps of give the permission and actually run the script, you could just replace the `node-env.sh` part with one of the currently available options:
>
> - `gjira/gjira-dependency-fix.sh`
> - `gjira-setup.sh`
> - `mysql-env.sh`
> - `node-env.sh`
> - `php-env.sh`
> - `postgres-env.sh`
> - `python-env.sh`
> - `shell-zsh.sh`
> - `m1/terraform-provider-template-fix.sh`

Most of the scripts aren't interactive, so they will configure everything at once. The exceptions are the `shell-zsh` and the `gjira-setup`, that ask for actions to be performed outside the terminal and ask for input data, respectively.

The `m1` directory is focused on storing scripts that only apply to M1 Macs. At the moment, we have only the `terraform-provider-template-fix` script, since we cannot run Terraform on Macs with ARM architecture without specific settings (in this case, locally building the provider) if the infrastructure needs providers that don't have builds for this architecture yet - as is the case of `terraform-provider-template`.
