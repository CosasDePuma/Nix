# Plan de Nixificación de Omarchy (`rice-omarchy`)

Este documento detalla el plan paso a paso para transformar el repositorio de distribución [Omarchy Linux](https://github.com/basecamp/omarchy) (clonado en `/tmp/omarchy`) en un módulo dendrítico 100% reproducible dentro de esta configuración de Nix (NixOS y Home Manager).

---

## 🎯 Objetivo General

Convertir el entorno de escritorio completo de Omarchy (diseñado por DHH) en un conjunto de componentes Nix declarativos:
1. **Composición Dendrítica**: Un solo módulo importable (`inputs.self.nixosModules.rice-omarchy` / `homeManagerModules.rice-omarchy`).
2. **Sin Mutabilidad ni Instaladores Imperativos**: Reemplazar scripts de bash que usan `pacman`, `yay` o escrituras en `/etc` por derivations de Nix (`stdenv.mkDerivation`, `writeShellApplication`) y opciones de Home Manager / NixOS.
3. **Fidelidad Estética y Funcional**: Preservar exactamente el diseño, las animaciones, la barra Quickshell, los 22 temas oficiales, los atajos de teclado y la suite de utilidades CLI de Omarchy.

---

## 📋 Fases del Plan

### Fase 1: Creación del Módulo Base y Host `wonderland` ── ✅ Completado
- [x] Estructurar el módulo en `dendritic/modules/rice/omarchy/default.nix`.
- [x] Exportar `nixosModules.rice-omarchy` y `homeManagerModules.rice-omarchy`.
- [x] Componer e importar automáticamente las dependencias en la infraestructura:
  - `software-hyprland` (UWSM, portal Wayland, soporte GPU)
  - `software-quickshell` (Wrappers de Qt6 / QML)
  - `settings-wayland` (Variables de entorno de Wayland/Ozone)
  - `software-warp` (Terminal por defecto: Warp Terminal)
  - `software-starship` (Prompt de shell)
  - `software-swaybg` (Fondo de pantalla)
  - `fonts-jetbrains` & `fonts-firacode` (Tipografías e iconos Nerd Fonts)
- [x] Crear el host desktop [wonderland](file:///home/wizard/Documents/nix/dendritic/hosts/desktop/x86_64-linux/wonderland/default.nix) aplicando `rice-omarchy`, `software-warp` y `meta-ai` (Antigravity, Claude, Herdr, Ollama, OpenCode, OpenSpec, Pi).
- [x] Desplegar la configuración inicial de `shell.json` para Quickshell y atajos esenciales de Hyprland (`SUPER + Return` -> `warp-terminal`).

---

### Fase 2: Nixificación de la Suite CLI de Omarchy (`omarchy-*`)
Los scripts ubicados en `/tmp/omarchy/bin/` contienen más de 400 comandos de utilidad (audio, captura, brillo, menús, bloqueo, control de energía, etc.).

- [ ] **Creación del paquete `pkgs.omarchy-cli`**:
  - Empaquetar `/tmp/omarchy/bin/*` mediante una receta Nix usando `stdenv.mkDerivation` o `symlinkJoin`.
  - Aplicar parches a las rutas absolutas (`/usr/share/omarchy`, `/usr/bin/...`) para usar variables `$OMARCHY_PATH` y binarios de Nix store.
- [ ] **Inyección de Dependencias de Runtime**:
  - Envolver los binarios usando `makeWrapper` garantizando que los siguientes binarios estén en `$PATH`:
    - Interactividad: `gum`, `fzf`, `jq`, `bc`
    - Audio: `wireplumber`, `pipewire`, `pamixer`, `playerctl`
    - Control de pantallas y OSD: `brightnessctl`, `ddcutil`, `libnotify`
    - Capturas & Media: `grim`, `slurp`, `wl-clipboard`, `imagemagick`, `ffmpeg`
    - Gestor de ventanas y sesión: `hyprland`, `hyprlock`, `hypridle`, `uwsm`
- [ ] **Desactivación/Adaptación de comandos orientados a Arch**:
  - Adaptar comandos como `omarchy-update`, `omarchy-pkg-add` o `omarchy-refresh-pacman` para dar avisos claros de que el sistema se gestiona de forma declarativa con `nixos-rebuild` / `nix flake update`.

---

### Fase 3: Motor de Temas y Gestión Dinámica de Wallpapers
Omarchy incluye 22 temas completos (Tokyo Night, Catppuccin, Rose Pine, Everforest, Kanagawa, Gruvbox, Nord, Hackerman, etc.) con paletas de colores, fondos de pantalla y variantes claras/oscuras.

- [ ] **Empaquetado de Recursos de Temas**:
  - Crear un paquete Nix `pkgs.omarchy-themes` que contenga todo el directorio `/tmp/omarchy/themes/`.
  - Desplegar la estructura de temas en `~/.config/omarchy/themes/` usando `xdg.configFile`.
- [ ] **Lógica de Conmutación de Temas (`omarchy-theme-set`)**:
  - Asegurar que `omarchy-theme-set` pueda actualizar dinámicamente:
    - Colores y transparencia de Hyprland
    - Tema de Warp / Ghostty / Kitty / Alacritty / Foot
    - Configuración de Starship
    - Fondo de pantalla activo con `swaybg`
    - Estilos de Quickshell y notificaciones

---

### Fase 4: Integración Avanzada de Hyprland & Quickshell
Omarchy utiliza una capa modular en Lua (`~/.config/hypr/*.lua` y `default/hypr/*.lua`) para configurar Hyprland.

- [ ] **Configuración Lua de Hyprland**:
  - Desplegar la suite de Lua bootstrap (`default/hypr/bootstrap.lua`, `envs.lua`, `bindings.lua`, `looknfeel.lua`, `monitors.lua`, `input.lua`) en `~/.config/hypr/` a través de Home Manager.
  - Habilitar la recarga dinámica con `SUPER + CONTROL + R`.
- [ ] **Integración de Quickshell & Demonios de Sesión**:
  - Desplegar los componentes QML de barra superior, menús desplegables y OSD.
  - Configurar `hypridle` para activar el salvapantallas a los 150 segundos y bloquear la pantalla (`hyprlock`) a los 300 segundos.
  - Configurar la pantalla de bloqueo `hyprlock` con los assets visuales de Omarchy.

---

### Fase 5: Menús, Lanzadores y Experiencia de Usuario
- [ ] **Lanzador Unificado (`omarchy-menu`)**:
  - Configurar el lanzador dinámico basado en `gum` / `fzf` / `rofi` / `walker` para aplicaciones, atajos, emojis y portapapeles.
- [ ] **Gestión de Portapapeles**:
  - Integrar `wl-clipboard` con `cliphist` para persistir el historial del portapapeles en `omarchy-menu-clipboard`.
- [ ] **Endurecimiento de Ejecución de Comandos**:
  - Evaluar `\exec` / `command exec` y rutas absolutas del store dentro de los scripts `omarchy-*` para impedir secuestro de PATH mediante aliases, funciones o binarios sombra. Los lanzadores críticos ya resuelven por ruta de store; aplazado hasta revisar el resto de scripts.

---

### Fase 6: Windows VM (Docker / Podman + RDP)
Omarchy ofrece la ejecución de Windows 11 Pro dentro de un contenedor Docker KVM con acceso directo mediante RDP.

- [ ] **Empaquetar la Windows VM (`software-windows-vm.nix`)**:
  - Utilizar `virtualisation.oci-containers.containers.windows` ejecutando la imagen `dockur/windows`.
  - Configurar aceleración por hardware `/dev/kvm`, RAM (ej. `8G`), CPU (ej. `4` núcleos) y montaje de directorio compartido `~/Windows`.
  - Crear lanzador `.desktop` en la barra y menú de Omarchy para iniciar la VM y conectar automáticamente con `wl-freerdp`.
  - Implementar script de auto-apagado del contenedor al cerrar la sesión RDP para liberar RAM y CPU.

---

### Fase 7: Habilitación en Hosts y Verificación Final ── ✅ Completado
- [x] Importar el módulo en el host [wonderland](file:///home/wizard/Documents/nix/dendritic/hosts/desktop/x86_64-linux/wonderland/default.nix).
- [x] Validar formateo con `nix fmt -- .`.
- [x] Comprobar validez de la flake con `nix flake check`.
- [x] Compilar el sistema completo (`nixos-rebuild build --flake .#wonderland`).

---

## 🚀 Despliegue Seguro, Pruebas y Rollback

Para aplicar cambios o cambiar de configuración de forma segura sin riesgo de romper el sistema:

### 1. Compilación de Prueba (Sin tocar el sistema)
```bash
nixos-rebuild build --flake .#wonderland
```
> Compila todo en el almacén de Nix (`/nix/store`) y crea el enlace `./result`. Si hay algún error sintáctico o de paquetes, fallará aquí sin alterar tu equipo.

### 2. Probar Temporalmente en Vivo (Sin alterar el cargador de arranque)
```bash
sudo nixos-rebuild test --flake .#wonderland
```
> Activa el entorno de inmediato en tu sesión actual. Si algo falla o si reinicias la máquina, **volverá automáticamente al estado anterior** sin dejar rastro en el menú de arranque de la BIOS.

### 3. Aplicar Permanentemente
```bash
sudo nixos-rebuild switch --flake .#wonderland
```
> Aplica el sistema y crea una nueva entrada en el menú de inicio (systemd-boot / GRUB).

### 4. Rollback en Caso de Fallo
- **Saber en qué generación estás**:
  ```bash
  nixos-rebuild list-generations
  ```
- **Volver a la generación anterior inmediatamente (en caliente)**:
  ```bash
  sudo nixos-rebuild switch --rollback
  ```
- **Desde la pantalla de inicio**: Si el sistema no arranca la sesión gráfica, selecciona la generación previa directamente en el menú de inicio de NixOS.

---

## 🛠️ Comandos Útiles para el Desarrollador

```bash
# Formatear el código nix
nix fmt -- .

# Verificar que las definiciones de la flake sean válidas
nix flake check

# Probar la construcción del módulo en el host wonderland
nixos-rebuild build --flake .#wonderland
```
