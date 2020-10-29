local kp =
  (import 'kube-prometheus/kube-prometheus.libsonnet') +
  // Uncomment the following imports to enable its patches
  // (import 'kube-prometheus/kube-prometheus-anti-affinity.libsonnet') +
  // (import 'kube-prometheus/kube-prometheus-managed-cluster.libsonnet') +
   (import 'kube-prometheus/kube-prometheus-node-ports.libsonnet') +
  // (import 'kube-prometheus/alertmanager/alertmanager.libsonnet') +
  // (import 'kube-prometheus/kube-prometheus-static-etcd.libsonnet') +
  // (import 'kube-prometheus/kube-prometheus-thanos-sidecar.libsonnet') +
  // (import 'kube-prometheus/kube-prometheus-custom-metrics.libsonnet') +
  {
    _config+:: {
      namespace: 'monitoring2',
      versions+:: {
        alertmanager: 'v0.21.0',
      },
      imageRepos+:: {
        alertmanager: 'quay.io/prometheus/alertmanager',
      },
      alertmanager+:: {
        name: 'main',
        config: {
          global: {
            resolve_timeout: '5m',
            smtp_smarthost: 'smtp.163.com:25',
            smtp_from: 'zheng13001570552@163.com',
            smtp_auth_username: 'zheng13001570552@163.com',
            smtp_auth_password: 'JQRLPDIPAYPEJXXE',
          },
          inhibit_rules: [{
            source_match: {
              severity: 'critical',
            },
            target_match_re: {
              severity: 'warning|info',
            },
            equal: ['namespace', 'alertname'],
          }, {
            source_match: {
              severity: 'warning',
            },
            target_match_re: {
              severity: 'info',
            },
            equal: ['namespace', 'alertname'],
          }],
          route: {
            group_by: ['namespace'],
            group_wait: '30s',
            group_interval: '5m',
            repeat_interval: '12h',
            receiver: 'Default',
          },
          receivers: [
            {
              name: 'Default',
              email_configs: [
                {to: '202821836@qq.com'},
  ],
            },
          ],
        },
        replicas: 3,
      },
    },
  };

{ ['setup/0namespace-' + name]: kp.kubePrometheus[name] for name in std.objectFields(kp.kubePrometheus) } +
{
  ['setup/prometheus-operator-' + name]: kp.prometheusOperator[name]
  for name in std.filter((function(name) name != 'serviceMonitor'), std.objectFields(kp.prometheusOperator))
} +
// serviceMonitor is separated so that it can be created after the CRDs are ready
{ 'prometheus-operator-serviceMonitor': kp.prometheusOperator.serviceMonitor } +
{ ['node-exporter-' + name]: kp.nodeExporter[name] for name in std.objectFields(kp.nodeExporter) } +
{ ['kube-state-metrics-' + name]: kp.kubeStateMetrics[name] for name in std.objectFields(kp.kubeStateMetrics) } +
{ ['alertmanager-' + name]: kp.alertmanager[name] for name in std.objectFields(kp.alertmanager) } +
{ ['prometheus-' + name]: kp.prometheus[name] for name in std.objectFields(kp.prometheus) } +
{ ['prometheus-adapter-' + name]: kp.prometheusAdapter[name] for name in std.objectFields(kp.prometheusAdapter) } +
{ ['grafana-' + name]: kp.grafana[name] for name in std.objectFields(kp.grafana) }
