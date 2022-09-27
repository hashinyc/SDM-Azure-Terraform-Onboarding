# [![strongDM](https://assets-global.website-files.com/5ecfe3add0194393eabdf182/5ecfebb04752d36bdbe9bdbf_dark.svg)](https://strongdm.com/)

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Docs](https://img.shields.io/badge/docs-current-brightgreen.svg)](https://strongdm.com/docs)
[![Twitter](https://img.shields.io/twitter/follow/strongdm.svg?style=social)](https://twitter.com/intent/follow?screen_name=strongdm)

## Quick Start strongDM with Terraform and Azure

This Terraform module gets you up and running with strongDM quickly by automating the creation of a variety of users, resources, and gateways. Keep reading to get hands-on experience and test strongDM's capabilities when integrating with Azure.

## Prerequisites

To successfully run the Azure Terraform module, you need the following:

- A strongDM administrator account. If you do not have one, [sign up](https://www.strongdm.com/signup-contact/) for a trial.
- A [strongDM API key](https://www.strongdm.com/docs/admin-ui-guide/access/api-keys/), which can be generated in the [strongDM Admin UI](https://app.strongdm.com/app/access/tokens). Your strongDM API key needs all permissions granted to it in order to generate the users and resources for these Terraform scripts.
- [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) v0.15.0 or higher installed on your computer.
- An Azure account and the ability to log in to local Azure CLI.

> **Warning:** These scripts create infrastructure resources in your Azure account, incurring Azure costs. Once you are done testing, remove these resources to prevent unnecessary Azure costs. You can remove resources manually or with `terraform destroy`. strongDM provides these scripts as is, and does not accept liability for any alterations to Azure assets or any Azure costs incurred.

## Run the Terraform Module

To work with the examples in this repository, follow these directions.

1. Clone the repository:

    ```shell
    git clone https://github.com/strongdm/SDM-Azure-Terraform-Onboarding.git
    ```

2. Switch to the directory containing the cloned project:

    ```shell
    cd SDM-Azure-Terraform-Onboarding
    ```

3. Initialize the working directory containing the Terraform configuration files:

    ```shell
    terraform init
    ```

4. Execute the actions proposed in the Terraform plan:

    ```shell
    terraform apply
    ```

5. The script asks you for the following values. If you prefer not to enter these values each time you run the module, you can store them in the `variables.tf` file found in the root of the project.

    - Your preferred Azure region
    - Your strongDM API key ID and secret
    - Your strongDM administrator email

Once you add these values, the script runs until it is complete. Note any errors. If there are no errors, you should see new resources, such as gateways, databases, or servers, in the strongDM Admin UI. Additionally, you should be able to look at your Azure portal to see the new instances.

## Customize the Terraform Module

You can optionally modify the `onboarding.tf` file to meet your needs, including altering the resource prefix, or spinning up additional resources which are commented out in the script.

To give you an idea of the script's total run time, estimates are provided to indicate the time it may take to spin up each resource after Terraform triggers it. Additionally, there are a few other items to consider in relation to the `onboarding.tf` file:

- You can add resource tags at the bottom of the file.
- You may choose not to provision any of the resources listed by simply commenting them out in the script, or altering their value to `false`. In order to successfully test, you need to keep at least one or more resource(s) and the strongDM gateways.

> **Note:** If you are using G Suite for an email provider, you may quickly and easily create more users without needing additional mailboxes. To do so, add `+anystring` to the end of the username in the email address. Google ignores the alias and delivers the email to the same inbox, allowing you to create aliases for various purposes while still receiving the mail in one place. Therefore, to create several sample users, you could just add `yourusername+user1@example.com`, `yourusername+user2@example.com`, and `yourusername+user3@example.com`.

### Conclusion

Feel free to create additional resources and to test as much as needed. If you have any questions, contact our support team at [support@strongdm.com](mailto:support@strongdm.com).

Once you are finished testing, remember to run `terraform destroy` from your project directory. With this command, Terraform deprovisions the Azure assets it created and it also removes the strongDM assets from the Admin UI. This clean ups after your testing and ensures that test assets do not accumulate unwanted costs while sitting unused.
