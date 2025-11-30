"""
PRISMA 2020 Flow Diagram API
Gera fluxogramas PRISMA 2020 compatíveis com as diretrizes oficiais
"""

from fastapi import FastAPI, HTTPException
from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field
from typing import Optional, Dict
import graphviz
import base64
import tempfile
import os

app = FastAPI(
    title="PRISMA 2020 API",
    description="API para geração de fluxogramas PRISMA 2020",
    version="1.0.0"
)


class PRISMASimpleInput(BaseModel):
    """Input simplificado para PRISMA"""
    identified: int = Field(..., description="Registros identificados nas bases de dados")
    duplicates: Optional[int] = Field(None, description="Duplicatas removidas (calculado automaticamente se não fornecido)")
    after_duplicates: Optional[int] = Field(None, description="Registros após remover duplicatas")
    screened: int = Field(..., description="Registros triados")
    excluded_screening: int = Field(..., description="Registros excluídos na triagem")
    sought_retrieval: int = Field(..., description="Relatórios buscados para recuperação")
    not_retrieved: Optional[int] = Field(0, description="Relatórios não recuperados")
    assessed_eligibility: int = Field(..., description="Relatórios avaliados para elegibilidade")
    excluded_fulltext: int = Field(..., description="Relatórios excluídos")
    exclusion_reasons: Optional[Dict[str, int]] = Field(None, description="Motivos de exclusão {'motivo': n}")
    included_studies: int = Field(..., description="Estudos incluídos na revisão")
    included_reports: Optional[int] = Field(None, description="Relatórios incluídos")


class PRISMAOutput(BaseModel):
    """Output da API"""
    success: bool
    base64: Optional[str] = None
    format: str = "png"
    message: str
    error: Optional[str] = None


def create_prisma_flowchart(data: PRISMASimpleInput) -> str:
    """Cria o fluxograma PRISMA 2020 usando Graphviz"""
    
    # Calcula valores derivados
    if data.duplicates is None and data.after_duplicates is not None:
        duplicates = data.identified - data.after_duplicates
    elif data.duplicates is not None:
        duplicates = data.duplicates
    else:
        duplicates = 0
    
    records_after_dup = data.identified - duplicates
    not_retrieved = data.not_retrieved or 0
    included_reports = data.included_reports or data.included_studies
    
    # Formata motivos de exclusão
    if data.exclusion_reasons:
        exclusion_text = "\\n".join([f"{k} (n={v})" for k, v in data.exclusion_reasons.items()])
    else:
        exclusion_text = f"Total excluídos (n={data.excluded_fulltext})"
    
    # Cria o grafo
    dot = graphviz.Digraph(
        'PRISMA',
        format='png',
        engine='dot'
    )
    
    # Configurações gerais
    dot.attr(rankdir='TB', splines='ortho', nodesep='0.5', ranksep='0.6')
    dot.attr('node', shape='box', style='filled', fontname='Arial', fontsize='10')
    
    # === IDENTIFICATION ===
    dot.attr('node', fillcolor='#b8d4e8')
    
    with dot.subgraph(name='cluster_id') as c:
        c.attr(label='Identificação', labeljust='l', style='rounded', color='#4a90a4', fontname='Arial', fontsize='11', fontcolor='#4a90a4')
        c.node('id_databases', f'Registros identificados nas\\nbases de dados\\n(n={data.identified})')
    
    # === SCREENING ===
    dot.attr('node', fillcolor='#d4e8b8')
    
    with dot.subgraph(name='cluster_screen') as c:
        c.attr(label='Triagem', labeljust='l', style='rounded', color='#6a9a4a', fontname='Arial', fontsize='11', fontcolor='#6a9a4a')
        c.node('dup_removed', f'Registros removidos antes da triagem:\\n\\nDuplicatas removidas (n={duplicates})')
        c.node('records_screened', f'Registros triados\\n(n={data.screened})')
        c.node('records_excluded', f'Registros excluídos\\n(n={data.excluded_screening})')
    
    # === ELIGIBILITY ===
    dot.attr('node', fillcolor='#e8d4b8')
    
    with dot.subgraph(name='cluster_elig') as c:
        c.attr(label='Elegibilidade', labeljust='l', style='rounded', color='#a4784a', fontname='Arial', fontsize='11', fontcolor='#a4784a')
        c.node('reports_sought', f'Relatórios buscados para\\nrecuperação\\n(n={data.sought_retrieval})')
        c.node('reports_not_retrieved', f'Relatórios não\\nrecuperados\\n(n={not_retrieved})')
        c.node('reports_assessed', f'Relatórios avaliados para\\nelegibilidade\\n(n={data.assessed_eligibility})')
        c.node('reports_excluded', f'Relatórios excluídos:\\n\\n{exclusion_text}')
    
    # === INCLUDED ===
    dot.attr('node', fillcolor='#b8e8d4')
    
    with dot.subgraph(name='cluster_inc') as c:
        c.attr(label='Inclusão', labeljust='l', style='rounded', color='#4aa474', fontname='Arial', fontsize='11', fontcolor='#4aa474')
        c.node('studies_included', f'Estudos incluídos na revisão\\n(n={data.included_studies})\\n\\nRelatórios incluídos\\n(n={included_reports})')
    
    # === EDGES (conexões) ===
    dot.attr('edge', color='#333333', arrowsize='0.8')
    
    # Fluxo principal
    dot.edge('id_databases', 'dup_removed')
    dot.edge('dup_removed', 'records_screened')
    dot.edge('records_screened', 'reports_sought')
    dot.edge('reports_sought', 'reports_assessed')
    dot.edge('reports_assessed', 'studies_included')
    
    # Exclusões (setas para o lado)
    dot.edge('records_screened', 'records_excluded')
    dot.edge('reports_sought', 'reports_not_retrieved')
    dot.edge('reports_assessed', 'reports_excluded')
    
    # Renderiza para arquivo temporário
    with tempfile.TemporaryDirectory() as tmpdir:
        filepath = os.path.join(tmpdir, 'prisma')
        dot.render(filepath, format='png', cleanup=True)
        
        # Lê o arquivo e converte para base64
        png_path = filepath + '.png'
        with open(png_path, 'rb') as f:
            img_data = f.read()
        
        return base64.b64encode(img_data).decode('utf-8')


@app.get("/health")
async def health_check():
    """Verifica se a API está online"""
    return {"status": "ok", "message": "PRISMA 2020 API está funcionando"}


@app.post("/generate-prisma-simple", response_model=PRISMAOutput)
async def generate_prisma_simple(data: PRISMASimpleInput):
    """
    Gera fluxograma PRISMA 2020 simplificado.
    
    Retorna imagem em base64.
    """
    try:
        b64_image = create_prisma_flowchart(data)
        
        return PRISMAOutput(
            success=True,
            base64=b64_image,
            format="png",
            message="Fluxograma PRISMA gerado com sucesso"
        )
    
    except Exception as e:
        return PRISMAOutput(
            success=False,
            format="png",
            message="Erro ao gerar fluxograma",
            error=str(e)
        )


@app.post("/generate-prisma")
async def generate_prisma(
    identified: int,
    duplicates: int = 0,
    screened: int = 0,
    excluded_screening: int = 0,
    sought_retrieval: int = 0,
    not_retrieved: int = 0,
    assessed_eligibility: int = 0,
    excluded_fulltext: int = 0,
    included_studies: int = 0,
    included_reports: int = None
):
    """
    Gera fluxograma PRISMA 2020 via query parameters.
    
    Alternativa ao endpoint POST com JSON.
    """
    try:
        data = PRISMASimpleInput(
            identified=identified,
            duplicates=duplicates,
            screened=screened,
            excluded_screening=excluded_screening,
            sought_retrieval=sought_retrieval,
            not_retrieved=not_retrieved,
            assessed_eligibility=assessed_eligibility,
            excluded_fulltext=excluded_fulltext,
            included_studies=included_studies,
            included_reports=included_reports
        )
        
        b64_image = create_prisma_flowchart(data)
        
        return {
            "success": True,
            "base64": b64_image,
            "format": "png",
            "message": "Fluxograma PRISMA gerado com sucesso"
        }
    
    except Exception as e:
        return {
            "success": False,
            "format": "png", 
            "message": "Erro ao gerar fluxograma",
            "error": str(e)
        }


# Documentação na raiz
@app.get("/")
async def root():
    return {
        "api": "PRISMA 2020 Flow Diagram API",
        "version": "1.0.0",
        "endpoints": {
            "GET /health": "Verifica status da API",
            "POST /generate-prisma-simple": "Gera fluxograma via JSON",
            "POST /generate-prisma": "Gera fluxograma via query params"
        },
        "docs": "/docs",
        "example_payload": {
            "identified": 450,
            "duplicates": 70,
            "screened": 380,
            "excluded_screening": 300,
            "sought_retrieval": 80,
            "not_retrieved": 5,
            "assessed_eligibility": 75,
            "excluded_fulltext": 45,
            "exclusion_reasons": {
                "Sem desfecho primário": 20,
                "População inadequada": 15,
                "Desenho inadequado": 10
            },
            "included_studies": 30
        }
    }
