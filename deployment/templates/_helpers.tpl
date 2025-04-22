{{- define "deployment.name" -}}
deployment
{{- end }}

{{- define "deployment.fullname" -}}
{{ include "deployment.name" . }}-{{ .Release.Name }}
{{- end }}

{{- define "deployment.chart" -}}
{{ .Chart.Name }}-{{ .Chart.Version }}
{{- end }}
