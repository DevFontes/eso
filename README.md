# External Secrets Operator (ESO) Infrastructure

Infraestrutura base para o External Secrets Operator com integração ao OCI Vault e Reflector para replicação de secrets entre namespaces.

## Componentes

### Core Infrastructure
- **External Secrets Operator** - Sincronização de secrets de vaults externos
- **Reflector** - Replicação automática de secrets entre namespaces
- **OCI Authentication Secret** - Credenciais para acesso ao OCI Vault

### Integrações
- **OCI Vault** - Vault externo para armazenamento seguro
- **Kubernetes Namespaces** - Isolamento e organização de recursos

## Arquitetura

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   OCI Vault     │ ←→ │  ESO Controller │ ←→ │  K8s Secrets    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                              │
                              ▼
                       ┌─────────────────┐
                       │   Reflector     │
                       │   (Replication) │
                       └─────────────────┘
                              │
                              ▼
                       ┌─────────────────┐
                       │  Other Namespaces│
                       └─────────────────┘
```

## Estrutura do Projeto

```
├── files/
│   └── values.yaml      # Configuração do ESO
├── main.tf              # ESO e namespace
├── oci-secret.tf        # Secret de autenticação OCI
├── reflector.tf         # Configuração do Reflector
├── providers.tf         # Providers Terraform
└── variables.tf         # Variáveis do projeto
```

## Pré-requisitos

- Kubernetes cluster
- Terraform >= 1.0
- OCI Vault configurado
- Credenciais OCI (private key + fingerprint)

## Variáveis Necessárias

### Opção 1: Export (Recomendado)
```bash
export TF_VAR_oci_fingerprint="aa:bb:cc:dd:ee:ff..."
export TF_VAR_oci_private_key="$(cat ~/.oci/oci_api_key.pem)"
```

### Opção 2: terraform.tfvars
```bash
echo 'oci_fingerprint = "aa:bb:cc:dd:ee:ff..."' >> terraform.tfvars
echo 'oci_private_key = file("~/.oci/oci_api_key.pem")' >> terraform.tfvars
```

## Deploy

```bash
terraform init
terraform plan
terraform apply
```

## Validação

Após o deploy, verifique a instalação:

```bash
# Verificar pods do ESO
kubectl get pods -n external-secrets

# Verificar CRDs
kubectl get crd | grep external-secrets

# Verificar Reflector
kubectl get pods -n reflector-system

# Verificar secret de autenticação
kubectl get secret oracle-secret -n external-secrets
```

## Uso em Outros Projetos

Outros projetos devem:

1. **Adicionar label aos namespaces** que precisam da secret:
   ```bash
   kubectl label namespace <namespace> eso-enabled=<namespace>
   ```

2. **Criar SecretStores** para conectar ao OCI Vault:
   ```yaml
   apiVersion: external-secrets.io/v1
   kind: SecretStore
   metadata:
     name: oci-vault
     namespace: <namespace>
   spec:
     provider:
       oracle:
         vault: <vault-ocid>
         region: <region>
         principalType: UserPrincipal
         auth:
           user: <user-ocid>
           tenancy: <tenancy-ocid>
           secretRef:
             privatekey:
               name: oracle-secret
               key: privateKey
             fingerprint:
               name: oracle-secret
               key: fingerprint
   ```

3. **Criar ExternalSecrets** para sincronizar secrets específicas:
   ```yaml
   apiVersion: external-secrets.io/v1
   kind: ExternalSecret
   metadata:
     name: my-secret
     namespace: <namespace>
   spec:
     secretStoreRef:
       name: oci-vault
       kind: SecretStore
     data:
       - secretKey: key1
         remoteRef:
           key: secret-name-in-vault
   ```

## Features

- ✅ ESO base infrastructure deployment
- ✅ OCI Vault authentication setup
- ✅ Automatic secret replication via Reflector
- ✅ Multi-namespace secret sharing
- ✅ Secure credential management
- ✅ Modular architecture for other projects

## Namespaces Suportados

Atualmente configurado para replicar secrets para:
- `monitoring` - Stack de observabilidade
- `nextcloud` - Aplicação Nextcloud

Para adicionar novos namespaces, edite a annotation no arquivo `oci-secret.tf`.