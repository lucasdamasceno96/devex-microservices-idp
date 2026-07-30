import streamlit as st
import os
import subprocess
import sys
from pathlib import Path

st.set_page_config(
    page_title="DevEx IDP - Service Factory",
    page_icon="",
    layout="centered",
)

st.title("DevEx IDP - Service Factory")
st.caption("Internal Developer Platform — Gere microsservicos em segundos")

REPO_PATH = os.environ.get("IDP_REPO_PATH", str(Path.home() / "Documents" / "coding" / "devex-microservices-idp"))
AR_REGISTRY = "us-central1-docker.pkg.dev/ldp21k-labs/devex-idp"

if "generated" not in st.session_state:
    st.session_state.generated = []
if "push_result" not in st.session_state:
    st.session_state.push_result = None

st.header("Novo Microsservico")

col1, col2 = st.columns(2)

with col1:
    service_name = st.text_input(
        "Nome do Servico *",
        placeholder="ex: order-service",
        help="Nome unico do microsservico. Sera usado como nome da imagem Docker e aplicacao ArgoCD.",
    )

    team = st.text_input(
        "Time *",
        placeholder="ex: orders-team",
        help="Nome do time dono do servico. Usado como label no Kubernetes.",
    )

with col2:
    port = st.number_input(
        "Porta HTTP *",
        min_value=1024,
        max_value=65535,
        value=3000,
        help="Porta onde o servico escuta. NestJS padrao: 3000.",
    )

    image_tag = st.text_input(
        "Tag da Imagem",
        value="latest",
        help="Tag Docker da imagem no Artifact Registry.",
    )

environments = st.multiselect(
    "Ambientes *",
    options=["dev", "staging", "production"],
    default=["dev", "staging", "production"],
    help="Em quais ambientes o servico sera implantado.",
)

st.divider()

if st.button("Gerar Microservico", type="primary", use_container_width=True):
    errors = []

    if not service_name:
        errors.append("Nome do servico e obrigatorio.")
    elif " " in service_name or not service_name.islower():
        errors.append("Nome do servico deve ser lowercase, sem espacos (ex: order-service).")

    if not team:
        errors.append("Time e obrigatorio.")

    if not environments:
        errors.append("Selecione pelo menos um ambiente.")

    if errors:
        for e in errors:
            st.error(e)
    else:
        with st.spinner(f"Gerando {service_name} nos ambientes {', '.join(environments)}..."):
            try:
                sys.path.insert(0, str(Path(__file__).parent))
                from generator import create_microservice

                files = create_microservice(
                    repo_path=REPO_PATH,
                    name=service_name,
                    team=team,
                    port=port,
                    environments=environments,
                )

                st.session_state.generated = files
                st.session_state.push_result = None

                st.success(f"Microservico **{service_name}** gerado com sucesso!")
                st.info(f"{len(files)} arquivo(s) GitOps criado(s) — aguardando push.")

            except Exception as e:
                st.error(f"Erro ao gerar microservico: {e}")

if st.session_state.generated:
    st.divider()
    st.subheader("Arquivos Gerados (commit local)")

    for f in st.session_state.generated:
        env = f.split("/")[-2]
        name = f.split("/")[-1]
        st.code(f"gitops/{env}/{name}", language=None)

    st.divider()

    col_a, col_b = st.columns(2)

    with col_a:
        if st.button("Push para Git (aciona ArgoCD)", type="secondary", use_container_width=True):
            with st.spinner("Enviando para o repositorio..."):
                try:
                    result = subprocess.run(
                        ["git", "push", "origin", "main"],
                        cwd=REPO_PATH,
                        capture_output=True,
                        text=True,
                        timeout=30,
                    )
                    if result.returncode == 0:
                        st.session_state.push_result = "ok"
                        st.success("Push concluido! ArgoCD detectara os novos arquivos e fara o deploy automaticamente.")
                    else:
                        st.session_state.push_result = "fail"
                        st.error(f"Erro no push:\n{result.stderr}")
                except subprocess.TimeoutExpired:
                    st.session_state.push_result = "fail"
                    st.error("Timeout no push. Execute manualmente: git push origin main")

    with col_b:
        if st.button("Limpar", use_container_width=True):
            st.session_state.generated = []
            st.session_state.push_result = None
            st.rerun()

    if st.session_state.push_result == "ok":
        st.divider()
        st.subheader("Resumo da Operacao")
        st.markdown(f"""
        | Campo | Valor |
        |-------|-------|
        | Servico | `{service_name}` |
        | Time | `{team}` |
        | Porta | `{port}` |
        | Ambientes | `{', '.join(environments)}` |
        | Imagem | `{AR_REGISTRY}/{service_name}:{image_tag}` |
        """)

        st.info(
            "O ArgoCD detectara os novos arquivos em `gitops/<ambiente>/<servico>.yaml` "
            "e aplicara o Helm Chart automaticamente. O deploy leva de 30 segundos a 2 minutos."
        )

st.sidebar.header("IDP Status")
st.sidebar.metric("Repositorio", REPO_PATH.split("/")[-1])
st.sidebar.metric("Artifact Registry", "ldp21k-labs/devex-idp")

try:
    import subprocess
    r = subprocess.run(["git", "log", "--oneline", "-5"], cwd=REPO_PATH, capture_output=True, text=True)
    if r.returncode == 0:
        st.sidebar.subheader("Commits Recentes")
        for line in r.stdout.strip().split("\n"):
            st.sidebar.caption(line)
except Exception:
    pass

st.sidebar.divider()
st.sidebar.caption("IDP Portal v1.0.0 — DevEx Platform Engineering")
