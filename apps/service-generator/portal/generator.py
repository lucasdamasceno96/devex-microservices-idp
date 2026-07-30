import yaml
import os
from datetime import datetime
from pathlib import Path
from git import Repo, Actor


REPO_URL = "https://github.com/lucasdamasceno96/devex-microservices-idp"
AR_REGISTRY = "us-central1-docker.pkg.dev/ldp21k-labs/devex-idp"
HELM_CHART_PATH = "platform/helm-chart"
GITOPS_BASE = "gitops"

ENV_CONFIGS = {
    "dev": {
        "replicaCount": 1,
        "NODE_ENV": "development",
        "LOG_LEVEL": "debug",
        "resources": {"requests": {"cpu": "128m", "memory": "128Mi"}, "limits": {"cpu": "256m", "memory": "256Mi"}},
    },
    "staging": {
        "replicaCount": 2,
        "NODE_ENV": "staging",
        "LOG_LEVEL": "info",
        "resources": {"requests": {"cpu": "256m", "memory": "256Mi"}, "limits": {"cpu": "512m", "memory": "512Mi"}},
    },
    "production": {
        "replicaCount": 3,
        "NODE_ENV": "production",
        "LOG_LEVEL": "warn",
        "resources": {"requests": {"cpu": "512m", "memory": "512Mi"}, "limits": {"cpu": "1000m", "memory": "1Gi"}},
    },
}


def generate_argo_application(name, environment, team, port, image_tag="latest"):
    cfg = ENV_CONFIGS[environment]

    return {
        "apiVersion": "argoproj.io/v1alpha1",
        "kind": "Application",
        "metadata": {
            "name": f"{name}-{environment}",
            "namespace": "argocd",
            "labels": {"team": team, "environment": environment, "generated-by": "idp-portal"},
        },
        "spec": {
            "project": "default",
            "source": {
                "repoURL": REPO_URL,
                "targetRevision": "main",
                "path": HELM_CHART_PATH,
                "helm": {
                    "values": yaml.dump({
                        "image": {
                            "repository": f"{AR_REGISTRY}/{name}",
                            "tag": image_tag,
                            "pullPolicy": "Always",
                        },
                        "replicaCount": cfg["replicaCount"],
                        "service": {"port": port},
                        "environment": {
                            "NODE_ENV": cfg["NODE_ENV"],
                            "LOG_LEVEL": cfg["LOG_LEVEL"],
                        },
                        "resources": cfg["resources"],
                        "autoscaling": {
                            "enabled": True,
                            "minReplicas": cfg["replicaCount"],
                            "maxReplicas": cfg["replicaCount"] * 5,
                            "targetCPUUtilizationPercentage": 75,
                        },
                        "otel": {
                            "enabled": True,
                            "exporterEndpoint": "http://otel-collector.observability:4317",
                        },
                    }),
                },
            },
            "destination": {
                "server": "https://kubernetes.default.svc",
                "namespace": environment,
            },
            "syncPolicy": {
                "automated": {
                    "prune": True,
                    "selfHeal": True,
                },
            },
        },
    }


def create_microservice(repo_path, name, team, port, environments):
    repo = Repo(repo_path)
    files_created = []

    for env in environments:
        app = generate_argo_application(name, env, team, port)
        yaml_path = Path(repo_path) / GITOPS_BASE / env / f"{name}.yaml"
        yaml_path.parent.mkdir(parents=True, exist_ok=True)
        with open(yaml_path, "w") as f:
            yaml.dump(app, f, default_flow_style=False, sort_keys=False, allow_unicode=True)
        files_created.append(str(yaml_path))

    author = Actor("idp-portal", "idp-portal@devex-microservices-idp.local")
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    repo.index.add(files_created)
    repo.index.commit(
        f"idp({name}): criar microservico {name} [{team}] em {', '.join(environments)}\n\n"
        f"Time: {team}\n"
        f"Porta: {port}\n"
        f"Ambientes: {', '.join(environments)}\n"
        f"Gerado pelo IDP Portal em {timestamp}",
        author=author,
    )

    return files_created
