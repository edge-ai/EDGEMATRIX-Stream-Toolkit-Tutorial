チュートリアル
=====================

#. 簡単な物体検出プロジェクトを準備する
#. 自作のイベントとコールバック関数を使用する
    #. 自作のコールバック関数を書く
    #. 自作のイベントを使う
    #. アプリケーションをテストする
#. 自前の入力ソースを使用する
    #. 自前のストリーミング用動画ファイルを用意する
    #. 自前のストリーム形式の動画ファイルを使用する
#. 自作の学習済モデルバイナリを使用する
    #. 自作の学習済モデルバイナリとその関連ファイルを配置する
    #. プロパティコンフィグレーションを変更する
#. IPluginで自作の学習済Yoloモデルバイナリを使用する
    #. DeepStream SDK上でYoloチュートリアルを行う
    #. 学習済Yoloモデルとその関連ファイルを配置する
    #. プロパティコンフィグレーションを変更する
#. IPluginで自作の学習済SSDモデルバイナリを使用する
    #. DeepStream SDK上でSSDチュートリアルを行う
    #. 学習済SSDモデルとその関連ファイルを配置する
    #. プロパティコンフィグレーションを変更する

--------------------------------------------------------
簡単な物体検出プロジェクトを準備する
--------------------------------------------------------

このチュートリアルでは、簡単な自動車検出器をカスタマイズしていきます。
まず、以下のようにプロジェクトを作成しましょう。

初めに、自動車テンプレートから、簡単な自動車検出器を作成します。

    .. image:: images/tutorials/mydetector.png
       :align: center

次に、`application_name` を、このアプリケーションを適切に表現する名前に変更します。

    .. image:: images/tutorials/mydetector_overview_editted.png
       :align: center

次に、一次推論の解像度を変更します。

    .. image:: images/tutorials/mydetector_input.png
       :align: center

.. TODO: トラッカー、一次推論、二次推論の意味がわからない。

テンプレートには、一次推論と同様に、トラッカーと二次モデル推論があります。
以下の"Remove"ボタンで、それぞれのプロパティを選択し、トラッカーと二次推論に関連するすべてのプロパティを削除しましょう。

    .. image:: images/tutorials/mydetector_removed_tracker_props.png
       :align: center

    .. image:: images/tutorials/mydetector_removed_secondary_proprs.png
       :align: center

次に、以下のように検出器のイベントアイテムを修正します。

    .. image:: images/tutorials/mydetector_events.png
       :align: center

この場合では、このアプリケーションは、トラッカーによって検出された物体それぞれのプロパティではなく、検出された物体の位置についてイベントを発生させていることに注意してください。

それでは、"Save"ボタンをクリックし、これらの変更を保存しましょう。
その後、SDKはアプリケーションを再読み込みします。

    .. image:: images/tutorials/mydetector_save.png
       :align: center

--------------------------------------------------------
自作のイベントとコールバック関数を使用する
--------------------------------------------------------

前節では、検出器に合わせてイベントアイテムを修正しました。

同様に、コールバック関数を更新する必要があります。

`applications` フォルダの `emi_signal_callback.py` にコールバック関数が定義されています。

    .. image:: images/tutorials/mydetector_ls.png
       :align: center

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
自作のコールバック関数を書く
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

次の内容を `emi_signal_callback.py` にコピーしてください。

.. code-block:: python

  from datetime import datetime

  ISO_FORMAT = '%Y-%m-%dT%H:%M:%S.%f%z'

  '''
  Vehicle Detector

  Keys:
      detected_datetime (string): The datetime when this object was detected
      left (number): The left coordinate of this object
      top (number): The top coordinate of this object
      width (number): The width of this object
      height (number): The height of this object
  '''

  class Car:

      def __init__(self, detected_timestamp, left, top, width, height, class_id, confidence):
          self.detected_timestamp = detected_timestamp
          self.left = left
          self.top = top
          self.width = width
          self.height = height
          self.class_id = class_id
          self.confidence = confidence

      def to_event_item(self):
          event_item = {
              'detected_timestamp': self.detected_timestamp,
              'left': self.left,
              'top': self.top,
              'width': self.width,
              'height': self.height,
              'class_id': self.class_id,
              'confidence': self.confidence
          }
          return event_item

      def iso_timestamp_to_datetime(timestamp):
          return datetime.strptime(timestamp, ISO_FORMAT)

  def update_tracking(signal):
      """ a signal callback function """
      debug_string = ''
      detected_cars = []
      frame_list = signal["frame"]
      for frame in frame_list:
          timestamp = frame['timestamp']
          objects = frame["object"]
          debug_string = debug_string + 'signal@' + timestamp + ':' + str(len(objects)) + 'objects\n'
          for obj in objects:
              class_id = obj['class_id']
              confidence = obj['confidence']
              rect_params = obj['rect_params']
              left = rect_params['left']
              top = rect_params['top']
              width = rect_params['width']
              height = rect_params['height']
              car = Car(timestamp, left, top, width, height, class_id, confidence)
              detected_cars.append(car.to_event_item())

      return detected_cars, debug_string

コールバック関数名は `update_tracking` のままにしましたが、全体的な内容は変更されました。

SDKに戻り、"Spell Check"を押下し、コールバックが正常に動作するか確認しましょう。

    .. image:: images/tutorials/mydetector_failed.png
       :align: center

おや、失敗してしまいました。
コンソールに以下のようなメッセージが表示されているはずです。

    .. image:: images/tutorials/mydetector_keyerror.png
       :align: center

これは「テンプレートを元に作成されたイベントに、`confidence` は存在しません」という内容です。
それでは、自作イベントを作成し、使ってみましょう。

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
自作のイベントを使う
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

以下の内容を、SDKルートフォルダ下の `signals` フォルダ内の `detector_signal.json` にコピーしてください。
このようなファイルを `applications` フォルダに配置してしまうと、正常に動作しないので注意してください。

.. code-block:: javascript

  {
      "frame": [
          {
              "frame": 1,
              "pts": 1,
              "timestamp": "2000-01-01T00:00:00.000000+0900",
              "object": [
                  {
                      "class_id": 0,
                      "confidence": 0.0,
                      "rect_params": {
                          "left": 0,
                          "top": 0,
                          "width": 0,
                          "height": 0
                      }
                  }
              ]
          }
      ]
  }

もう一つ忘れられていた `rect_params` というキーも追加されていることに注意してください。

それでは、もう一度"Spell Check"をしてみましょう。
このとき、`detector_signal.json` を選択することを忘れないでください。
"Execute"を押下すると、アプリケーションがチェックを通過したことが確認できます。

    .. image:: images/tutorials/mydetector_passed.png
       :align: center

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
アプリケーションをテストする
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

それでは最後に、アプリケーションをテストしましょう。

アプリケーションを実行するためには、`streams` フォルダを作成する必要があります。

`vehicle_stream` フォルダをコピーし、`mydetector_stream` という名前に変更してください。

現在、フォルダ構成は次のようになっているはずです。

    .. image:: images/tutorials/mydetector_streams_ls.png
       :align: center

もしクイックスタートから来ていて、他のファイルやフォルダがある場合には、`vehicle_by_make_counter_stream_configuration.json` 以外のすべてのファイルを削除してください。

`vehicle_by_make_counter_stream_configuration.json` を `mydetector_stream_configuration.json` にリネームし、以下の内容をコピーしてください。

.. code-block:: javascript

  {
    "stream_id": "mydetector_stream",
    "created": "2019-07-23T09:10:29.842496+09:00",
    "last_updated": "2019-07-24T10:11:30.842496+09:00",
    "revision": 3,
    "stream_type": "rtsp",
    "location": "rtsp://127.0.0.1:8554/test",
    "mode": "sender",
    "roi": {
      "left": 0,
      "right": 0,
      "top": 0,
      "bottom": 0
    },
    "action_rules": [
      {
        "rule_name": "Vehicle Recording",
        "and": [
          {
            "key": "width",
            "operator": ">",
            "value": 100
          },
          {
            "key": "height",
            "operator": ">",
            "value": 100
          }
        ],
        "or": [],
        "action": {
          "action_name": "record",
          "duration_in_seconds": 3
        }
      },
      {
        "rule_name": "Upload to AWS Kinesis Firehose",
        "and": [
          {
            "key": "width",
            "operator": ">",
            "value": 100
          },
          {
            "key": "height",
            "operator": ">",
            "value": 100
          }
        ],
        "or": [],
        "action": {
          "action_name": "upload",
          "deliveryStreamName": "trafficStream",
          "accessKey": "",
          "secretKey": "",
          "region": ""
        }
      }
    ],
    "application_package": {
      "filename": "mydetector.zip",
      "license": "ABC01234"
    }
  }

サンプルビデオファイルを使って `mydetector_stream` フォルダ内のアプリケーションを実行すると、以下のように表示されます。
これは、それぞれのイベントのアップロードアクションが、幅・高さともに100以上で正常に作成されたことを示しています。

    .. image:: images/tutorials/mydetector_execute.png
       :align: center

また、レコーディングアクションが実行され、`recordings` フォルダの中に動画ファイルが生成されます。

    .. image:: images/tutorials/mydetector_execute_streams_ls.png
       :align: center

--------------------------------------------------------
自前の入力ソースを使用する
--------------------------------------------------------

自作の動画ファイルを使用するのにすべきことは、アプリケーションの実行時にそれを選択することだけです。

しかし、動画ファイルを作成するには、以下のいくつかのルールを守る必要があります。

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
自前のストリーミング用動画ファイルを用意する
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

アプリケーション実行時に選択された動画ファイルは、ローカルのRTSPストリームのソースとして内部で使用されています。

このような動画ファイルコンテナはmp4である必要があります。
他のコンテナでも動作はするかもしれませんが、正常にテストできません。

ローカルのRTSPストリームは、H.264にハードコードされています。
そのため、自作の動画ファイルのエンコーディングもH.264でなければなりません。

また、ビットレートが高いと、いくつかの問題が生じます。
そのため、720p (1280x720)の30 fps以下のファイルを推奨します。

さらに、動画ファイルはストリーム形式でなければなりません。
これは、すべての必要な情報がファイルの先頭に配置されていることを意味します。

これは、 `qtfastart` で確認できます。
例えば、サンプル動画ファイルでは以下のように表示されます。

    .. image:: images/tutorials/mydetector_qtfaststart.png
       :align: center

また、`qtfaststart` を使えば、ファストスタートでないファイルをファストスタートに変換することもできます。

.. code-block:: bash

  $ qtfaststart NON_FASTSTART_FILE FASTSTART_FILE

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
自前のストリーム形式の動画ファイルを使用する
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

これは、ファストスタートでないファイルの例です。

    .. image:: images/tutorials/mydetector_faststart_kanagawa.png
       :align: center

アクション)

    .. image:: images/tutorials/mydetector_kanagawa_actions.png
       :align: center

デバッグウィンドウ)

    .. image:: images/tutorials/mydetector_kanagawa_debug.png
       :align: center

--------------------------------------------------------
自作の学習済モデルバイナリを使用する
--------------------------------------------------------

準備中です。

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
自作の学習済モデルバイナリとその関連ファイルを配置する
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

準備中です。

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
プロパティコンフィグレーションを変更する
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

準備中です。

--------------------------------------------------------
IPluginで自作の学習済Yoloモデルバイナリを使用する
--------------------------------------------------------

もし学習済の自作Yoloモデルをお持ちであれば、以下のNVIDIAのガイドを参照してください。

`Custom YOLO Model in the DeepStream YOLO App <https://docs.nvidia.com/metropolis/deepstream/4.0.1/Custom_YOLO_Model_in_the_DeepStream_YOLO_App.pdf>`_

このチュートリアルでは、DeepStream 4.0.1に搭載されているサンプルYolo検出器を使用する方法を紹介します。

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
DeepStream SDK上でYoloチュートリアルを行う
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

初めに、`こちら <https://drive.google.com/open?id=1em99dle1ejsvzJxDJdkW8yzbYWrN7wj_>`_ からDeepStreamパッケージをダウンロードしてください。

パッケージを展開したら、プロジェクトディレクトリに移動し、READMEファイルにしたがってカスタムライブラリをビルドしましょう。

.. code-block:: bash

  $ cd sources/objectDetector_Yolo/
  $ ./prebuild.sh
  $ export CUDA_VER=10.0
  $ make -C nvdsinfer_custom_impl_Yolo

次に、正常に動作するか確認するためにdeepstream-appを起動します。
また、最初の起動時には、TensorRTエンジンファイルが作成されます。

.. code-block:: bash

  $ deepstream-app -c deepstream_app_config_yoloV3_tiny.txt

Tiny Yolo V3アプリケーションは、Jetson TX2のFP32モードでは約50 fpsで動作することに注意してください。
異なるYoloのバージョンを試し、パフォーマンスを確認してみてください。

Tiny Yolo V3のコンフィグレーションは次節で使用します。

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
学習済Yoloモデルバイナリとその関連ファイルを配置する
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

それでは、Yoloモデルバイナリとその関連ファイルを用いてEAPファイルパッケージを作成してみましょう。

簡単な検出器のプロジェクトフォルダを `applications` フォルダにコピーし、"My Yolo Detector"と名前をつけてください。

次に、`resource` フォルダ下のすべてのテキストファイルとsoファイルを削除してください。
また、`resource/models/` フォルダ下の `Primary_Detector` フォルダ内のすべてのファイルと `Secondary_CarColor` フォルダも削除してください。

これで、古いファイルはすべて削除できました。
それでは、新しいファイルを配置していきましょう。

`config_infer_primary_yoloV3_tiny.txt` と `nvdsinfer_custom_impl_Yolo/libnvdsinfer_custom_impl_Yolo.so` を `resource` フォルダにコピーしてください。
その後、次のファイルを `resource/models/Primary_Detector` フォルダにコピーしてください。

* labels.txt
* model_b1_fp32.engine
* yolov3_tiny.cfg
* yolov3_tiny.weights

現時点で、フォルダ構造はこのようになっています。

    .. image:: images/tutorials/myyolodetector_ls.png
       :align: center

まだSDKを開いている場合はそれを閉じ、新しいアプリケーションを開いて読み込んでください。

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
プロパティコンフィグレーションを変更する
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

"Primary"タブで変更すべきプロパティは、`config_file_path` のみです。

    .. image:: images/tutorials/myyolodetector_primary.png
       :align: center

プロパティを変更したら、設定を保存しましょう。
次に、`config_infer_primary_yoloV3_tiny.txt` を開き、以下のようにプロパティを更新します。
`model-engine-file` プロパティがコメントアウトされ、`.gpg` 拡張子が追加されていることを確認してください。

    .. image:: images/tutorials/myyolodetector_diff.png
       :align: center

前の手順にしたがって、以下のようにmydetector_streamでアプリケーションを起動できます。

アクション)

    .. image:: images/tutorials/myyolodetector_actions.png
       :align: center

デバッグウィンドウ)

    .. image:: images/tutorials/myyolodetector_debug.png
       :align: center

--------------------------------------------------------
IPluginで自作の学習済SSDモデルバイナリを使用する
--------------------------------------------------------

この節は、前節のYoloモデルの例と酷似しています。

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
DeepStream SDK上でSSDチュートリアルを行う
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

もしDeepStreamパッケージをダウンロードしていなければ、`こちら <https://drive.google.com/open?id=1em99dle1ejsvzJxDJdkW8yzbYWrN7wj_>`_ からダウンロードしてください。

パッケージを展開したら、プロジェクトディレクトリに移動し、READMEファイルにしたがって、カスタムライブラリをビルドしましょう。

.. code-block:: bash

  $ cd sources/objectDetector_SSD/
  $ cp /usr/src/tensorrt/data/ssd/ssd_coco_labels.txt ./
  $ apt search uff-converter
  $ pip3 show tensorflow-gpu
  $ wget http://download.tensorflow.org/models/object_detection/ssd_inception_v2_coco_2017_11_17.tar.gz
  $ tar xzvf ssd_inception_v2_coco_2017_11_17.tar.gz
  $ cd ssd_inception_v2_coco_2017_11_17/
  $ python3 /usr/lib/python3.6/dist-packages/uff/bin/convert_to_uff.py \
           frozen_inference_graph.pb -O NMS \
           -p /usr/src/tensorrt/samples/sampleUffSSD/config.py \
           -o sample_ssd_relu6.uff
  $ cd ..
  $ cp ssd_inception_v2_coco_2017_11_17/sample_ssd_relu6.uff ./
  $ export CUDA_VER=10.0
  $ make -C nvdsinfer_custom_impl_ssd

次に、正常に動作するか確認するためにdeepstream-appを起動します。
また、最初の起動時には、TensorRTエンジンファイルが作成されます。

.. code-block:: bash

  $ deepstream-app -c deepstream_app_config_ssd.txt

SSDアプリケーションはJetson TX2のFP32モードでは約21 fpsで動作することに注意してください。

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
学習済SSDモデルとその関連ファイルを配置する
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

それでは、SSDモデルバイナリとその関連ファイルを用いてEAPファイルパッケージを作成してみましょう。

簡単な検出器のプロジェクトフォルダを `applications` フォルダにコピーし、"My SSD Detector"と名前をつけてください。

次に、`resource` フォルダ内のすべてのテキストファイルとsoファイルを削除してください。
また、`resource/models` フォルダ下の `Primary_Detector` フォルダ内のすべてのファイルと `Secondary_CarColor` フォルダも削除してください。

これで、古いファイルはすべて削除できました。
それでは、新しいファイルを配置していきましょう。

`config_infer_primary_ssd.txt` と `nvdsinfer_custom_impl_ssd/libnvdsinfer_custom_impl_ssd.so` を `resource` フォルダにコピーしてください。
その後、次のファイルを `resource/models/Primary_Detector` にコピーしてください。

* sample_ssd_relu6.uff
* sample_ssd_relu6.uff_b1_fp32.engine
* ssd_coco_labels.txt

現時点で、フォルダ構造はこのようになっています。

    .. image:: images/tutorials/myssddetector_ls.png
       :align: center

まだSDKを開いている場合はそれを閉じ、新しいアプリケーションを開いて読み込んでください。

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
プロパティコンフィグレーションを変更する
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

"Primary"タブで変更すべきプロパティは、 `config-file-path` のみです。

    .. image:: images/tutorials/myssddetector_primary.png
       :align: center

プロパティを変更したら、設定を保存しましょう。
次に、`config_infer_primary_ssd.txt` を開き、以下のようにプロパティを更新します。
`.gpg` 拡張子が追加されていることを確認してください。

    .. image:: images/tutorials/myssddetector_diff.png
       :align: center

前の手順にしたがって、以下のようにmydetector_streamでアプリケーションを起動できます。

アクション)

    .. image:: images/tutorials/myssddetector_actions.png
       :align: center

デバッグウィンドウ)

    .. image:: images/tutorials/myssddetector_debug.png
       :align: center
