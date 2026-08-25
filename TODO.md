# TODO — Nixificación de Omarchy (`rice-omarchy`)

Roadmap para acercar `dendritic/modules/rice/omarchy/` y el host
`wonderland` al Omarchy upstream (clon de referencia en `/tmp/omarchy`)
de forma 100% declarativa. Detalle histórico en
[PLAN.md](dendritic/modules/rice/omarchy/PLAN.md).

Hallazgo clave: el vendor de `software-omarchy-shell` ya incluye todos los
plugins oficiales (`menu`, `lock`, `notifications`, `osd`, `panels`,
`polkit`, `reminders`, `emojis`, `clipboard`, `background`), así que la
prioridad es **usar la shell en vez de re-implementarla** con
fuzzel/hyprlock/swaybg.

## 1. Menú real vía IPC Quickshell ── ✅ Completado

- [x] Reescribir `omarchy-menu` como thin-wrapper IPC al plugin
  `omarchy.menu` (`omarchy-shell shell toggle omarchy.menu '<json>'`),
  espejo del `bin/omarchy-menu` upstream: verbos `toggle|summon|close|refresh`
  + rutas (`root`, `system`, `capture`, `theme`, `toggle`, `apps`...).
- [x] Reescribir `omarchy-menu-clipboard` como toggle del plugin
  `omarchy.clipboard` (upstream: `SUPER+CTRL+V`; aquí sigue en `SUPER+V`).
- [x] Eliminar el servicio `omarchy-cliphist`: el plugin clipboard trae sus
  propios watchers `wl-paste --watch capture.sh`; actualizar comentario
  sobre fuzzel (solo queda el theme-switcher usándolo hasta resolver el
  punto 2).

## 2. Unificar el layout de estado de temas

- [ ] Migrar `omarchy-theme-switcher` al estado upstream
  `~/.local/state/omarchy/current/theme/` (hoy escribe
  `~/.config/omarchy/current-theme`, que nadie lee; la barra lee el otro).
- [ ] Wallpaper gestionado por el estado de tema / plugin `background`
  en vez de `pkill swaybg`.

## 3. Lock e idle nativos de la shell ── ✅ Completado

- [x] Quitar hypridle/hyprlock de `home.packages` (HM) y
  `environment.systemPackages` (NixOS); `hyprsunset` se queda: el plugin
  nightlight de la shell lo maneja vía `hyprctl hyprsunset temperature`.
- [x] `omarchy-system-lock` → `omarchy-shell lock lock` + reset best-effort
  de layout de teclado (`hyprctl switchxkblayout all 0`), espejo upstream.
- [x] El idle lo impone la propia shell: `plugins/services/idle/Service.qml`
  lee los tiempos de `shell.json` (150s screensaver / 300s lock).
- [x] Nuevo `service-omarchy-lock`: registra los servicios PAM
  `omarchy-lock-password` (siempre) y `omarchy-lock-fingerprint`
  (condicionado a `services.fprintd.enable`) que exige
  `plugins/lock/Service.qml`; sustituye a `service-hyprlock` como import
  de `rice-omarchy`.
- Nota: el salvapantallas upstream usa `omarchy-launch-screensaver` +
  `ttfx`; sin él el idle sigue bloqueando a los 300s pero no dibuja el
  efecto. Portarlo junto al punto 4 si interesa.

## 4. Suite CLI como derivación única (Fase 2 del PLAN.md)

- [ ] `symlinkJoin "omarchy-cli"` con los scripts seleccionados de
  `/tmp/omarchy/bin` (~433), parcheando `$OMARCHY_PATH` → store.
- [ ] Prioridad inmediata — los 8 que la shell invoca por
  `$OMARCHY_PATH/bin/`: `omarchy-clipboard-open`,
  `omarchy-clipboard-paste-file`, `omarchy-clipboard-paste-text`,
  `omarchy-hyprland-focus-app`, `omarchy-menu-emoji-insert`,
  `omarchy-notification-send`, `omarchy-reminder`,
  `omarchy-remove-launcher-entry`. Sin ellos esas acciones del menú/barra
  fallan.
- [ ] Stub de los pacman/yay/AUR con aviso de flujo nixos-rebuild.
- [ ] Orden de portado posterior: `capture-*`, `audio-*`, `brightness-*`,
  `theme-*`, `toggle*`, `system-*`. Cada tanda desbloquea sus binds.

## 5. Completar binds hacia `default/hypr/bindings/utilities.lua`

- [ ] Familia `SUPER+comma`: dismiss/invoke/historial de notificaciones.
- [ ] `PRINT` (captura), `ALT+PRINT` (screenrec),
  `SUPER+PRINT` (color picker), `SUPER+CTRL+PRINT` (OCR).
- [ ] `SUPER+CTRL+1..9` toggles de paneles de la barra.
- [ ] Zoom de cursor, `SUPER+K` (visor de keybindings),
  `omacalc` (calculadora).
- [ ] Hacerlo junto al punto 4 para no bindear scripts inexistentes.

## 6. Fidelidad de looknfeel

- [ ] Decidir conscientemente: espejar el default upstream sobrio
  (`rounding=0`, blur/shadow off) o documentar la desviación actual
  (rounding=10, blur/shadow on) como rice propio.

## 7. Generalizar el motor de temas (después)

- [ ] Extraer helpers compartidos de render (colors.toml → cada formato)
  para que un nuevo `themes-*` sea datos + imports; upstream tiene
  plantillas para ~18 apps (`default/themed/*.tpl`).
- [ ] Respetar la regla de AGENTS.md: cada tema sigue siendo un leaf
  auto-detectado, sin imports incondicionales.

## Limpiezas menores

- [ ] `environment.systemPackages` del módulo NixOS duplica casi toda la
  lista de `home.packages`; dejar en sistema solo lo útil en TTY.
- [ ] Windows VM: ya existe (`software-windowsvm`); solo falta el
  lanzador/entrada de menú cuando el menú real esté (punto 1).
- [ ] Investigar mako vs plugin `notifications` de la shell: si el plugin
  reclama `org.freedesktop.Notifications`, mako sobra (y su unidad
  systemd con él); hoy conviven y uno gana la carrera del nombre D-Bus.
