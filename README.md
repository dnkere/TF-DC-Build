# TF-SlackSlash-Root-Template-Repo
This repo is a template that contains a structured layout and sample TF code for creating [Slack slash commands](https://api.slack.com/interactivity/slash-commands).


## Prerequisites
1. Have an available account in [Amazon AWS](https://aws.amazon.com/) and/or [Microsoft Azure](https://azure.microsoft.com/en-us/).
2. Download and install [Terraform](https://www.terraform.io/downloads.html).
3. Download and install [Python 3.8](https://www.python.org/downloads/release/python-382/).
4. Download and install [NodeJS](https://nodejs.org/en/).
5. Download and install the [AWS CLI](https://aws.amazon.com/cli/).
6. Download and install the [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest).

### Makefile
What is [Make](https://www.gnu.org/software/make/)? With Terraform we are using it like a Macro that takes X and does Y to get Z. Make is only used when running Terraform locally for initial development or testing.  Make is a mature tool that's been used to compile code for many years.  It is quite common in the \*nix community, and is an excellent tool to wrap other tools and commands that you might commonly use in your project.

With Terraform we are using it to automate certain actions and reduce the number of steps needed to build an environment. Make is primarily a \*nix toolset that can be installed with your package manager of choice, install build-essential. There is also a Windows version, however this will have have issues as there are shell commands that won't work in Windows. We recommend installing [Windows Subsystem for Linux](https://docs.microsoft.com/en-us/windows/wsl/about). With this and your distro of choice, Make can be installed. Also with VSCode, a WSL console can be added so it is super easy to use Make on Windows.

Make uses a file called a `Makefile` which is located in each terraform root, and contains the rules for execution of various tasks.  Execute a bare `make` in order to view a simple help.

### Running Terraform Locally with Make
When in a Terraform root, simply typing `make` will show what make can do when called with the following rule. In this instance, there are the following:
```
apply                          Have terraform do the things. This will cost money.
destroy-target                 Destroy a specific resource. Caution though, this destroys chained resources.
destroy                        Destroy the things
plan-destroy                   Creates a destruction plan.
plan-target                    Shows what a plan looks like for applying a specific resource
plan                           Show what terraform thinks it will do
quick-apply                    Have terraform do the things, but without an init. This will cost money.
quick-plan                     Show what terraform thinks it will do, but no init first
```
