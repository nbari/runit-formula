{% from "runit/map.jinja" import conf with context %}

runit:
  pkg.installed:
    - name: {{ conf.runit }}
  service.running:
    - name: {{ conf.service }}
    - enable: True
    - restart: True
    - require:
      - pkg: runit
    - watch:
      - file: runit
{% if grains['os_family'] == 'FreeBSD' %}
  file.managed:
    - name: /etc/rc.conf.d/runsvdir
    - template: jinja
    - source: salt://runit/files/runsvdir
    - require:
      - pkg: runit
{% else %}
      - file: /etc/environment
  file.managed:
    - name: /usr/sbin/runsvdir-start
    - template: jinja
    - source: salt://runit/files/runsvdir-start
    - user: root
    - group: root
    - mode: 755
    - require:
      - pkg: runit
{% endif %}

{{ conf.SVDIR }}:
  file.directory:
    - makedirs: True
    - require:
      - pkg: runit

{% if grains['os_family'] == 'Debian' %}
SVDIR_environment:
  file.append:
    - name: /etc/environment
    - text:
      - SVDIR={{ conf.get('SVDIR', '/service') }}
    - require:
      - pkg: runit
{% endif %}

/bin/sv:
  file.symlink:
    - target: {{ conf.sv_path }}
    - require:
      - pkg: runit
