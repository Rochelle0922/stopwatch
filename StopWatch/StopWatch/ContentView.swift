//
//  ContentView.swift
//  StopWatch
//
//  Created by 이연정 on 7/11/24.
//

import SwiftUI

struct StopWatchView: View {
  @State var isStarted: Bool = false
  @State var elapsedMiliSecond = 0
  @State var elapsedSecond = 0
  @State var elapsedMinute = 0
  @State var timer: Timer?
  @State var lapArray: [String] = []
  @State var showReset: Bool = false
  @State var lapStartTime: (minute: Int, second: Int, miliSecond: Int) = (0, 0, 0)
  
  var body: some View {
    VStack {
      Spacer().frame(height: 110)
      Text(createTimeString())
        .font(.system(size: 80, weight: .thin))
        .kerning(1.2)
        .multilineTextAlignment(.center)
        .padding()
        .monospacedDigit()
      
      Spacer().frame(height: 80)
      HStack {
        Button(action: {
          lapOrResetButtonTapped()
        }) {
          Text(showReset ? "재설정" : "랩")
            .frame(width: 90, height: 90)
            .background(Color.gray.opacity((isStarted || (!isStarted && (elapsedMinute > 0 || elapsedSecond > 0 || elapsedMiliSecond > 0))) ? 0.5 : 0.2))
          // 타이머가 시작되지 않았고 00:00:00인 경우 opacity 0.2
            .foregroundColor(.white)
            .clipShape(Circle())
        }
        .disabled(!isStarted && lapArray.isEmpty)
        
        Spacer()
        
        Button(action: {
          startOrStopButtonTapped()
        }) {
          Text(isStarted ? "중단" : "시작")
            .frame(width: 90, height: 90)
            .background(isStarted ? Color.red.opacity(0.3) : Color.green.opacity(0.3))
            .foregroundColor(isStarted ? .red : .green)
            .clipShape(Circle())
        }
      }
      .padding(.bottom, 10)
      
      ScrollView {
        LazyVStack {
          let (fastestLapIndex, slowestLapIndex) = getFastestAndSlowestLapIndices()
          ForEach(lapArray.indices.reversed(), id: \.self) { index in
            VStack {
              HStack {
                Text("랩 \(index + 1)")
                  .font(.headline)
                  .foregroundColor(index == fastestLapIndex ? .green : (index == slowestLapIndex ? .red : .primary))
                Spacer()
                Text(lapArray[index])
                  .font(.body)
                  .foregroundColor(index == fastestLapIndex ? .green : (index == slowestLapIndex ? .red : .primary))
                  .multilineTextAlignment(.trailing)
                  .monospacedDigit()
              }
              .padding(.vertical, 5)
              Divider()
            }
          }
        }
      }
    }
    .padding()
  }
  
  func startOrStopButtonTapped() {
    if isStarted {
      timer?.invalidate()
      isStarted = false
      showReset = true
    } else {
      createTimer()
      if lapArray.isEmpty {
        lapStartTime = (elapsedMinute, elapsedSecond, elapsedMiliSecond)
        lapArray.append(createTimeString(from: lapStartTime))
      }
      isStarted = true
      showReset = false
    }
  }
  
  func lapOrResetButtonTapped() {
    if isStarted {
      lapArray.append(createTimeString(from: lapStartTime))
      lapStartTime = (elapsedMinute, elapsedSecond, elapsedMiliSecond)
    } else {
      lapArray.removeAll()
      elapsedMinute = 0
      elapsedSecond = 0
      elapsedMiliSecond = 0
      showReset = false
    }
  }
  
  func createTimer() {
    timer?.invalidate()
    timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
      updateTime()
      if isStarted && !lapArray.isEmpty {
        lapArray[lapArray.count - 1] = createTimeString(from: lapStartTime)
      }
    }
  }
  
  func updateTime() {
    elapsedMiliSecond += 5
    if elapsedMiliSecond >= 100 {
      elapsedSecond += 1
      elapsedMiliSecond = 0
    }
    if elapsedSecond >= 60 {
      elapsedMinute += 1
      elapsedSecond = 0
    }
  }
  
  func createTimeString(from startTime: (minute: Int, second: Int, miliSecond: Int)? = nil) -> String {
    let startTime = startTime ?? (0, 0, 0)
    let totalMiliSecond = (elapsedMinute - startTime.minute) * 6000 + (elapsedSecond - startTime.second) * 100 + (elapsedMiliSecond - startTime.miliSecond)
    let miliSecond = totalMiliSecond % 100
    let totalSeconds = totalMiliSecond / 100
    let second = totalSeconds % 60
    let minute = totalSeconds / 60
    
    let miliSecondString = miliSecond < 10 ? "0\(miliSecond)" : "\(miliSecond)"
    let secondString = second < 10 ? "0\(second)" : "\(second)"
    let minuteString = minute < 10 ? "0\(minute)" : "\(minute)"
    return "\(minuteString):\(secondString).\(miliSecondString)"
  }
  
  func getFastestAndSlowestLapIndices() -> (Int?, Int?) {
    guard lapArray.count >= 3 else { return (nil, nil) }
    
    let staticLaps = Array(lapArray.dropLast())
    let lapTimes = staticLaps.map { lapString -> Int in
      let components = lapString.split(separator: ":")
      let minutes = Int(components[0]) ?? 0
      let secondsComponents = components[1].split(separator: ".")
      let seconds = Int(secondsComponents[0]) ?? 0
      let miliSeconds = Int(secondsComponents[1]) ?? 0
      return (minutes * 60 + seconds) * 100 + miliSeconds
    }
    
    guard let minTime = lapTimes.min(), let maxTime = lapTimes.max() else {
      return (nil, nil)
    }
    
    let fastestLapIndex = lapTimes.firstIndex(of: minTime)
    let slowestLapIndex = lapTimes.firstIndex(of: maxTime)
    return (fastestLapIndex, slowestLapIndex)
  }
}

struct StopWatchView_Previews: PreviewProvider {
  static var previews: StopWatchView {
    StopWatchView()
  }
}
