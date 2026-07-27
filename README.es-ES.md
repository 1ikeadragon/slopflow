# slopflow

Una capa de disciplina basada en evidencia y con criterio propio para **Claude Code** y **Codex**: el antídoto contra el "AI slop" (contenido mediocre de IA).

Los agentes de programación son rápidos, fluidos y seguros. Esa confianza es el problema: infieren comportamientos a partir de nombres de archivos, confían en comentarios obsoletos, afirman que las cosas "ya están implementadas", colapsan la inferencia en hechos y optimizan para sonar decisivos en lugar de tener razón. slopflow instala un conjunto compartido de reglas siempre activas más una biblioteca de habilidades que fuerzan los hábitos opuestos: fundamentar las afirmaciones en evidencia ejecutable, rastrear la ruta real de producción, razonar antes de converger y preservar la incertidumbre en lugar de ocultarla.

## Qué instala
slopflow implementa dos capas:

1. **Prompt siempre activo**: instrucciones globales cargadas en cada sesión.
   - Claude → `~/.claude/CLAUDE.md`
   - Codex → `~/.codex/AGENTS.md`
   - Estos contienen las Reglas Principales (evidencia antes que afirmaciones, ruta de producción primero, hecho vs inferencia, auditorías de pérdida de señal y de métricas/oráculos, verificaciones de razonamiento a nivel meta), un mapa compacto de enrutamiento de habilidades, la puerta de seguridad y la disciplina de salida. El procedimiento detallado reside en las habilidades, no aquí.

2. **Habilidades (Skills)**: flujos de trabajo enfocados que se cargan bajo demanda cuando coinciden sus disparadores. Instalados en `~/.claude/skills/<skill>/` y `~/.codex/skills/<skill>/`. El procedimiento detallado reside aquí para que el prompt siempre activo se mantenga ligero.

## Instalación

```sh
git clone https://github.com/1ikeadragon/slopflow.git
cd slopflow
./install.sh
```

El instalador debe ejecutarse desde un checkout completo (verifica la existencia de `CLAUDE.md`, `AGENTS.md` y `skills/`).

| Bandera | Efecto |
| --- | --- |
| `--dry-run` | Imprime cada acción sin tocar el sistema de archivos. |
| `--claude-only` | Instala solo el objetivo para Claude. |
| `--codex-only` | Instala solo el objetivo para Codex. |
| `-h`, `--help` | Uso. |

Anulaciones de entorno:

| Variable | Predeterminado | Propósito |
| --- | --- | --- |
| `CLAUDE_HOME` | `~/.claude` | Raíz de instalación de Claude. |
| `CODEX_HOME` | `~/.codex` | Raíz de instalación de Codex. |
| `SLOPFLOW_BACKUP_ROOT` | `~/.slopflow-backups/<timestamp>` | Donde se respaldan los archivos sobrescritos. |

### Seguridad y respaldos

El instalador nunca destruye silenciosamente tu configuración existente:

- Cualquier archivo de prompt o habilidad del mismo nombre que esté a punto de sobrescribir se copia primero a `~/.slopflow-backups/<timestamp>/`, reflejando su ruta original.
- Los respaldos de habilidades obsoletos en el sitio con nombres `*.bak.*` se mueven fuera de la raíz de habilidades hacia el directorio de respaldo, para que no se carguen como habilidades.
- La habilidad retirada `security-review` es eliminada (después de ser respaldada).

Previsualiza todo primero con `./install.sh --dry-run`.

### Desinstalación / restauración

No hay un desinstalador. Para revertir, restaura los archivos relevantes desde el directorio `~/.slopflow-backups/<timestamp>/` más reciente (el cual refleja las rutas originales) y elimina cualquier directorio de habilidad de slopflow que ya no desees de `~/.claude/skills/` y `~/.codex/skills/`.

## Habilidades (Skills)
Soy malo poniendo nombres, así que acepta estos nombres cursis :pray:

| Habilidad | Úsala para |
| --- | --- |
| `reasoning-discipline` | La columna vertebral del razonamiento, aplicada por defecto a trabajos no triviales / ambiguos / de alto riesgo: encuadrar → generar opciones → verificar → diagnosticar → evaluar → decidir → sintetizar, más autoverificaciones a nivel meta. |
| `evidence-first` | Fundamentar cualquier afirmación no trivial en evidencia ejecutable; clasificar el código como producción / prueba / legado; preservar la incertidumbre. |
| `implementation-discipline` | Realizar el cambio correcto más pequeño, con un plan + auditoría de plan antes de programar y una auditoría post-implementación después. |
| `architecture-review` | Mapear el cableado activo, puntos de entrada, flujo de datos/control, variantes de tiempo de ejecución y modos de falla antes de proponer un diseño. |
| `code-review-discipline` | Cazar regresiones, llamadores ocultos, casos borde, brechas de error y pruebas débiles. Corrección sobre cortesía. |
| `adversarial-test-design` | Pruebas impulsadas por invariantes que atacan suposiciones, para seguridad, criticidad de corrección, parsers, flujos de trabajo y lógica de IA/LLM. |
| `legacy-cleanup` | Clasificar el código por alcanzabilidad antes de la eliminación; decisiones de cuarentena/eliminación con validación. |
| `rca-investigation` | Análisis de causa raíz (RCA) acumulativo e impulsado por pruebas con hipótesis competitivas y rastreo de código/configuración/DB/git. |
| `workflow-rca` | Recopilar evidencia de flujo de trabajo/tiempo de ejecución (IDs de Temporal/CI, logs de nube, artefactos, estado de caché) para alimentar `rca-investigation`. |
| `rigorous-web-research` | Investigación externa actual con citas estrictas: prácticas de competidores, documentación primaria, artículos recientes, benchmarks. |
| `agent-system-design` | Diseñar o revisar sistemas agentes: bucles de LLM, herramientas, contexto/estado, traspasos, guardrails, rastreo, evaluaciones y calidad de prompts/habilidades. |
| `data-validation` | Validar programáticamente conjuntos de datos, registros analizados, tablas, logs, conteos, métricas, resultados de matrices y afirmaciones dependientes de datos. |
| `secure-design` | Revisión de modelo de amenazas por subcomponente para cambios relevantes de seguridad, activada a través de la Puerta de Seguridad siempre activa. |

El instalador descubre automáticamente cada directorio bajo `skills/` que contenga un `SKILL.md`, por lo que añadir una habilidad es simplemente añadir una carpeta.

## Filosofía
- **Evidencia antes que afirmaciones.** Los nombres de archivos, comentarios y READMEs son pistas, no pruebas.
- **Ruta de producción primero.** Rastrea desde un punto de entrada real antes de juzgar o cambiar el comportamiento.
- **Separa el hecho de la inferencia.** Observado / Inferido / Incierto / Conclusión.
- **Sin pérdida de señal oculta.** Señala cada atajo, mock, fallback o truncamiento y su riesgo.
- **Razona antes de converger.** Encuadra el problema, genera alternativas reales, decide deliberadamente.
- **Los prompts deben trabajar.** Elimina virtudes "no-op" a menos que se conviertan en reglas de decisión observables, verificaciones de validación o comportamiento ante fallos.
- **Preserva la incertidumbre.** Una respuesta incierta pero correcta es mejor que una falsa pero segura.

## Créditos
La habilidad `reasoning-discipline` se inspira en la habilidad `overthink` de s0md3v.

## Licencia

[MIT](./LICENSE)
