# Protótipo para medir distância

Protótipo para medir distâncias de dispositivos bluetooth.

Para funcionar com todos os dispositvos, incluindo os BLE, foi implementado nativamente e por meio de event channel e method channel, executa a busca e retorna a lista dos dispositivos com a estimativa de distância em metros pelos métodos LDPLM e Friis de cálculo de distância.

Os cálculos foram baseados no artigo "Avaliação de Técnicas de Localização de Dispositivos BLE para a Physical Web e Prova de Conceito"

## Aplicativo

Para usar o aplicativo pode ser feito por meio do download nesse link [https://raw.githubusercontent.com/felipebeskow/medir_distancia_bluetooth/main/binary/app.apk](https://raw.githubusercontent.com/felipebeskow/medir_distancia_bluetooth/main/binary/app.apk) ou compilando o código desse repositório, seguindo os seguinte passos:

```
git clone https://github.com/felipebeskow/medir_distancia_bluetooth
cd medir_distancia_bluetooth
flutter run
```

## Fonte:
[Avaliação de Técnicas de Localização de Dispositivos BLE para a Physical Web e Prova de Conceito](https://bdm.unb.br/bitstream/10483/17781/1/2017_GuilhermeDavid_SamuelVinicius_tcc.pdf)
