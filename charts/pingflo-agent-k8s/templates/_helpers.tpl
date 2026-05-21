{{/*
  Standard helper template — name + label generators.
*/}}

{{- define "pingflo-agent-k8s.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "pingflo-agent-k8s.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{- define "pingflo-agent-k8s.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "pingflo-agent-k8s.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "pingflo-agent-k8s.labels" -}}
helm.sh/chart: {{ include "pingflo-agent-k8s.chart" . }}
{{ include "pingflo-agent-k8s.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: pingflo
app.kubernetes.io/component: agent-k8s
{{- end }}

{{- define "pingflo-agent-k8s.selectorLabels" -}}
app.kubernetes.io/name: {{ default .Chart.Name .Values.nameOverride }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
