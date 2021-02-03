{% from 'allowed_states.map.jinja' import allowed_states %}
{% if sls in allowed_states %}

{% from 'salt/map.jinja' import COMMON with context %}

include:
  - salt.minion
  - systemd.reload

salt_master_package:
  pkg.installed:
    - pkgs:
      - {{ COMMON }}
      - salt-master
    - hold: True

salt_master_service:
  service.running:
    - name: salt-master
    - enable: True
    - watch:
      - module: reload_systemd
      - file: salt_minion_systemd

salt_master_systemd:
  file.managed:
    - name: /etc/systemd/system/multi-user.target.wants/salt-master.service
    - source: salt://salt/systemd/salt-master.service

checkmine_engine:
  file.managed:
    - name: /etc/salt/engines/checkmine.py
    - source: salt://salt/engines/checkmine.py
    - makedirs: True
    - watch_in:
        - service: salt_minion_service

engines_config:
  file.managed:
    - name: /etc/salt/minion.d/engines.conf
    - source: salt://salt/files/engines.conf
    - watch_in:
        - service: salt_minion_service



{% else %}

{{sls}}_state_not_allowed:
  test.fail_without_changes:
    - name: {{sls}}_state_not_allowed

{% endif %}