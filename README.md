# terraform-docker-iac

**Task 3 – Infrastructure as Code (IaC) with Terraform**

Provision a local Docker container (nginx) using Terraform and the Docker provider, then inspect the state and destroy everything again.

## What the code does

`main.tf` has:
- **Provider:** `kreuzwerker/docker` (v3.x), which talks to the local Docker engine.
- **`docker_image.nginx`:** pulls the `nginx:alpine` image.
- **`docker_container.nginx`:** runs a container named `terraform-nginx` and maps host port **8081** to container port 80.
- **Variables:** `container_name` and `external_port`.
- **Outputs:** the container name and the URL `http://localhost:8081`.

The container uses `docker_image.nginx.image_id`, so Terraform knows to create the image first (resource dependency).

## Commands I ran (logs are in `logs/`)

| Step | Command | Log |
| --- | --- | --- |
| 1 | `terraform init` | `logs/01-init.log` |
| 2 | `terraform validate` | `logs/02-validate.log` |
| 3 | `terraform plan` (shows 2 to add) | `logs/03-plan.log` |
| 4 | `terraform apply -auto-approve` | `logs/04-apply.log` |
| 5 | `terraform state list` | `logs/05-state-list.log` |
| 6 | `terraform state show docker_container.nginx` | `logs/06-state-show.log` |
| 7 | `docker ps` (container running) | `logs/07-docker-ps.log` |
| 8 | `curl localhost:8081` ("Welcome to nginx!") | `logs/08-curl.log` |
| 9 | `terraform destroy -auto-approve` | `logs/09-destroy.log` |
| 10 | `docker ps` (container gone) | `logs/10-docker-ps-after-destroy.log` |
| 11 | `terraform state list` (empty) | `logs/11-state-list-after-destroy.log` |

I ran this in a GitHub Codespace, which already has Docker. Terraform was installed with the HashiCorp apt repository.

## How to run it yourself

```bash
terraform init
terraform plan
terraform apply
# open http://localhost:8081  (you should see "Welcome to nginx!")
terraform state list
terraform destroy
```

Port 8081 is used so it does not clash with other tools on 8080 (for example Jenkins). Change it with `terraform apply -var="external_port=9090"`.

## Files

- `main.tf`: the Terraform code
- `.terraform.lock.hcl`: locks the provider version
- `.gitignore`: keeps `.terraform/` and state files out of git
- `logs/`: execution logs

State files (`terraform.tfstate`) are not committed because they can contain sensitive data.

## Interview questions

**1. What is IaC?**
Infrastructure as Code means describing servers, networks and containers in text files instead of clicking in a console. The files live in git, so infrastructure can be reviewed, versioned, repeated and rebuilt automatically.

**2. How does Terraform work?**
I write the desired infrastructure in `.tf` files. `terraform init` downloads providers, `plan` compares my code with the real infrastructure and the state file, and `apply` makes only the needed changes by calling the provider's API (here, Docker).

**3. What is the Terraform state file?**
`terraform.tfstate` is Terraform's record of the resources it created and their current attributes. Terraform uses it to know what already exists, to detect changes, and to know what to destroy. It can contain secrets, so it should not go in git; teams keep it in a remote backend (for example S3 with locking).

**4. What is the difference between apply and plan?**
`plan` only shows what would change and changes nothing. `apply` actually creates, updates or deletes resources. Running `plan` first lets me review the change before making it.

**5. What are Terraform providers?**
Providers are plugins that let Terraform talk to a platform's API, such as AWS, Azure, Kubernetes or Docker. In this task the provider is `kreuzwerker/docker`, downloaded by `terraform init`.

**6. What is resource dependency?**
It is the order in which resources must be created. Terraform builds a dependency graph. My container refers to `docker_image.nginx.image_id`, so Terraform creates the image first and destroys it last. Dependencies can also be set with `depends_on`.

**7. How do you handle secret variables?**
Mark the variable `sensitive = true` so it is hidden in output, pass values through environment variables (`TF_VAR_name`) or a `.tfvars` file that is in `.gitignore`, and never hard-code secrets in `.tf` files. For real projects use a secrets manager (Vault, AWS Secrets Manager) and an encrypted remote state, because secrets can still appear in the state file.

**8. Explain the benefits of Terraform.**
Repeatable and consistent environments, version-controlled infrastructure, a safe preview with `plan`, support for many clouds and tools with one workflow, automatic dependency handling, and easy cleanup with `destroy`.
