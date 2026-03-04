# 🚁 ArDrone Controller for iPad

![Swift: 5.9](https://img.shields.io/badge/Swift-5.9-F05138.svg?style=flat) ![Platform: iOS](https://img.shields.io/badge/Platform-iOS%20|%20iPadOS-lightgrey.svg?style=flat) ![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)

> **English** | [한국어](#-ardrone-controller-for-ipad-korean)

A beautifully crafted, modern iOS/iPadOS application designed to fly DIY drones (MultiWii / Arduino-based) over Bluetooth LE using the MultiWii Serial Protocol (MSP). Built entirely from scratch using SwiftUI and Combine, this open-source controller provides a minimal, ergonomic, and latency-free flying experience right from your iPad.

## ✨ Features
* **Modern SwiftUI Interface**: Enjoy an aesthetic, responsive "liquid glass" style control center perfectly fitted for iPad.
* **Flawless MSP Implementation**: Complete translation of AETR (Roll, Pitch, Yaw, Throttle) into accurate MSP Packets (Command `150` & `101`).
* **Ergonomic Virtual Joysticks**: 2D touch pads engineered for thumbs—featuring auto-centering for Pitch/Roll/Yaw, and a stepped analog slider for Throttle.
* **Real-time Telemetry Dashboard**: Live monitoring of drone State, Armed Status, 4-Axis RC Output, and Motor commands.
* **On-the-fly Maintenance**: Built-in `Acc Calibration` and `Factory Reset` to manage hardware without plugging into a computer.
* **Robust Bluetooth State Management**: Auto-reset mechanisms to prevent PID wind-ups and runaway motor spins upon connection drops.

## 🛠 Hardware Architecture Example (The $30 AI Drone)
Have an old Arduino and some generic drone parts? You don't need a $1,000 rig to start building.
1. **Flight Controller**: Any Arduino Nano/Uno running [MultiWii 2.4 Firmware](https://code.google.com/archive/p/multiwii/) (Tested with `AirCopter` codebase).
2. **Bluetooth Module**: HM-10 BLE Module (Connects Serial TX/RX to Arduino).
3. **Drone Frame & Motors**: Standard F450 frame with 4x ESCs and DC/Brushless Motors.

## 🚀 Getting Started
1. Clone this repository and open the project in **Xcode 15+**.
2. Run the application on a physical iPad (BLE does not work on the simulator).
3. Power on your MultiWii drone.
4. Tap the connection bar to discover devices, select your Bluetooth module (e.g., HM-10), and tap **Arm** to fly!

---

# 🚁 ArDrone Controller for iPad (Korean)

이 프로젝트는 아두이노(MultiWii) 기반의 자작 드론을 블루투스(BLE) 통신으로 조종할 수 있게 해주는 모던한 iOS/iPadOS 애플리케이션입니다. 저렴한 부품들로 조립한 드론을 아이패드의 유려하고 세련된 UI 위에서 완벽히 통제해 보세요!

## ✨ 주요 기능
* **SwiftUI 기반 최신 UI/UX**: 아이패드에 최적화된 유려하고 직관적인 투명한 컨트롤 패널 뷰.
* **안정적인 MSP 프로토콜**: AETR(상하좌우 회전) 데이터를 표준 MultiWii 시리얼 프로토콜로 지연 없이 부호화하여 전송합니다.
* **인체공학적 가상 조이스틱**: 스프링복귀(Auto-center) 기능이 적용된 2D 가상 스틱과 세밀 조작을 위한 스텝형 스로틀 슬라이더를 제공합니다.
* **실시간 원격 측정(Telemetry)**: 드론의 시동(Armed) 상태, 아두이노가 실제 수신 중인 4축 조종값, 4개의 모터 출력값을 앱 화면에서 실시간으로 관찰할 수 있습니다.
* **유지보수 단축키 지원**: 센서가 틀어졌을 때 앱에서 즉시 `가속도계 영점(Acc Calibrate) 조절` 및 `공장 초기화(Factory Reset)`를 실행할 수 있습니다.
* **안전(Failsafe) 장치**: 통신이 끊어지거나 재연결되는 찰나의 순간에 모터가 폭주(PID Wind-up)하는 것을 막기 위해 모든 조종간 출력을 중립화(Reset) 합니다.

## 🛠 무자본(?) 하드웨어 추천 세팅
집에 굴러다니는 아두이노와 3만원 어치 부품만 있다면, 아이패드로 조종하는 나만의 자율주행 드론을 탄생시킬 수 있습니다!
1. **비행 컨트롤러 (FC)**: [MultiWii 2.4](https://code.google.com/archive/p/multiwii/) 스케치가 올라간 아두이노 나노(Nano) 또는 우노(Uno).
2. **통신 모듈**: 저전력 블루투스(BLE) 모듈 HM-10. 보드의 아두이노 Serial TX/RX 핀에 연결합니다.
3. **기체 및 모터**: 저렴한 F450 프레임과 프로펠러, 4개의 ESC 및 브러시리스 모터.

## 🚀 시작하기
1. 프로젝트를 클론(Clone)한 뒤 **Xcode 15** 이상에서 엽니다.
2. 실제 iPad 기기를 연결하여 앱을 빌드합니다 (시뮬레이터에서는 블루투스가 작동하지 않습니다).
3. 드론 마스터 배터리를 켜고 전원을 인가합니다.
4. 상단 [연결하기] 바를 눌러 블루투스 장비(HM-10)를 찾아 페어링한 뒤, **Arm(시동)** 버튼을 누르고 비행하세요!

---
*Created by [adgk2349]* | *Pull Requests are always welcome!*
