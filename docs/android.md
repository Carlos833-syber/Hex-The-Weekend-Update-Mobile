# Android APK — Hex: The Weekend Update

## Gerar pelo GitHub

1. Abra **Actions → Android APK → Run workflow**, selecione a branch com o port e execute.
2. Aguarde o job `apk` terminar. O workflow também roda em pull requests e pushes nas branches configuradas.
3. Baixe **Hex-Weekend-Android-debug** em **Artifacts**, extraia o ZIP e instale o APK no celular.

O APK usa assinatura de depuração, inclui ARMv7 e ARM64, exige Android 5.0 (API 21) ou superior e abre em paisagem. É um build para testes/instalação direta, não uma publicação na Play Store. Cada runner pode criar uma assinatura de depuração diferente; se uma atualização falhar por assinatura, desinstale a versão anterior (isso remove os saves). Para distribuição estável, configure assinatura de release própria fora deste workflow.

## Controles e opções

- Quatro regiões de toque para as notas; suportam múltiplos dedos e notas sustentadas.
- Os botões de navegação permitem usar menus, confirmar, voltar e pausar sem teclado.
- **Options → Appearance → Middle Scroll** centraliza as notas do jogador.
- **Options → Appearance → Hitboxes** alterna o desenho das áreas de toque; ocultar o desenho mantém os controles ativos.

A base continua sendo Kade Engine, com controles de toque no estilo da hitbox da Psych Engine.

## Compilar localmente

Instale Haxe **4.2.5**, Neko **2.3.0**, Python 3, Java **11** e o Android SDK. Na raiz do repositório:

```bash
sdkmanager "platforms;android-33" "build-tools;30.0.3" "ndk;21.4.7075529"
bash scripts/setup-android.sh
haxelib run lime config ANDROID_SDK "$ANDROID_HOME"
haxelib run lime config ANDROID_NDK_ROOT "$ANDROID_HOME/ndk/21.4.7075529"
haxelib run lime config JAVA_HOME "$JAVA_HOME"
haxelib run lime config ANDROID_SETUP true
haxelib run lime build android -debug -D HXCPP_CHECK_POINTER
```

O APK fica em `export/debug/android/bin/app/build/outputs/apk/debug/`.

O script fixa Lime 7.9.0, OpenFL 9.2.0, HaxeFlixel 4.11.0 e as demais bibliotecas compatíveis com esta base. Também aplica o renderer customizado descrito no README, substitui o repositório Maven aposentado JCenter e adapta o manifesto do Lime para Android 12+. Use um diretório Haxelib separado se outros projetos precisarem das bibliotecas sem esses patches. A configuração Android usa Gradle 6.7.1 e Android Gradle Plugin 4.2.2.

## Limitações e validação em aparelho

- As bibliotecas VLC/WebM fornecidas são para desktop. Neste port inicial, as cenas MP4 avançam automaticamente para o diálogo e o vídeo de fundo de **Cooling** fica transparente; áudio e gameplay continuam. Não há implementação de vídeo nativo Android neste APK.
- Lua modcharts, Discord e leitura de músicas StepMania externas continuam exclusivos do desktop. Efeitos dependentes de Lua não serão executados no Android.
- O workflow precisa concluir a compilação para disponibilizar o APK. Verificação de tipos Haxe não substitui compilação C++/Gradle nem teste em aparelho.
- Teste o primeiro boot, Story/Freeplay, acordes e sustains, pausa/retorno, perda de foco, persistência das opções, Cooling e a passagem dos diálogos. Assets grandes e shaders podem exigir bastante memória/GPU.
