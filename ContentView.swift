//
//  ContentView.swift
//  SwiftUIListTest
//
//  Created by Kearen Samsel on 6/10/23.
//

import SwiftUI

struct listItem: Identifiable {
    let id = UUID()
    let isTray: Bool
    let trayData: tray?
    var cardData: card?
}

struct tray: Identifiable {
    let id = UUID()
    let trayID: Int
    let name: String
    let colorNumber: Int
}

struct card: Identifiable {
    var id = UUID()
    let name: String
    let favNumber: Int
    var inheritID: Int
}

func getTrayForIndex(listIndex: Int, listItems: [listItem]) -> Int { // finds the nearest tray to a dropped card item
    for loopIndex in 0..<listIndex {
        let reverseLoopIndex = listIndex - loopIndex
        if listItems[reverseLoopIndex - 1].isTray {
            return listItems[reverseLoopIndex - 1].trayData!.trayID
        }
    }
    return 0
}

struct ContentView: View {
    @State var listItems: [listItem] = [
        listItem(isTray: true, trayData: tray(trayID: 1, name: "tray 1", colorNumber: 1), cardData: nil),
        listItem(isTray: false, trayData: nil, cardData: card(name: "card 1", favNumber: 2, inheritID: 1)),
        listItem(isTray: false, trayData: nil, cardData: card(name: "card 2", favNumber: 32, inheritID: 1)),
        listItem(isTray: true, trayData: tray(trayID: 2, name: "tray 2", colorNumber: 3), cardData: nil),
        listItem(isTray: false, trayData: nil, cardData: card(name: "card 3", favNumber: -1, inheritID: 2)),
        listItem(isTray: false, trayData: nil, cardData: card(name: "card 4", favNumber: 29, inheritID: 2)),
        listItem(isTray: true, trayData: tray(trayID: 3, name: "tray 3", colorNumber: 1), cardData: nil),
        listItem(isTray: false, trayData: nil, cardData: card(name: "card 5", favNumber: 2, inheritID: 3)),
        listItem(isTray: false, trayData: nil, cardData: card(name: "card 6", favNumber: 32, inheritID: 3)),
        listItem(isTray: true, trayData: tray(trayID: 4, name: "tray 4", colorNumber: 3), cardData: nil),
        listItem(isTray: false, trayData: nil, cardData: card(name: "card 7", favNumber: -1, inheritID: 4)),
        listItem(isTray: false, trayData: nil, cardData: card(name: "card 8", favNumber: 29, inheritID: 4))
    ]
    @State private var openTrays: [Bool] = [false, false, false, false]
    @State private var draggingTray: Bool = false
    var body: some View {
        List {
            ForEach(0..<listItems.count) { listIndex in
                let oneListItem = listItems[listIndex]
                listItemView(openTrays: $openTrays, draggingTray: $draggingTray, displayIndex: listIndex, oneListItem: oneListItem)
                    .onDrag { // only for detecting when drag is initiated in order to collapse the trays.
                        self.draggingTray = oneListItem.isTray
                        return NSItemProvider() // There's gotta be a better way to detect this, but I have no idea how.
                    }
            }
            .onMove { source, destination in
                let isTray = (listItems[source.first ?? 1].isTray)
                if isTray {
                    var cardsSource: IndexSet = IndexSet(listItems.indices.filter({ listItems[$0].cardData?.inheritID == listItems[source.first ?? 1].trayData!.trayID })) // gets IndexSet for all cards in tray group
                    var newDestination: Int
                    if destination == 0 { // If an item is being moved to index zero, don't look further backwards for a tray value
                        newDestination = 0
                    } else {
                        let aboveTrayID = listItems[destination - 1].trayData?.trayID ?? listItems[destination - 1].cardData!.inheritID // get the TrayID from the tray/card above the destination
                        newDestination = listItems.indices.filter({listItems[$0].cardData?.inheritID == aboveTrayID}).last ?? 0 //get the last index + 1 of the above trayID's cards
                        newDestination += 1
                    }
                    cardsSource.formUnion(source) // add the tray's cards to the destination IndexSet
                    listItems.move(fromOffsets: cardsSource, toOffset: newDestination)
                } else {
                    let newInheritID = getTrayForIndex(listIndex: destination, listItems: listItems) // finds the tray above where a card is being moved
                    source.forEach { sourceItem in
                        self.listItems[sourceItem].cardData!.inheritID = newInheritID //update all sources to match the above tray's trayID
                    }
                    openTrays[newInheritID - 1] = true // opens the tray that the card is being moved to

                    listItems.move(fromOffsets: source, toOffset: destination)
                }
                self.draggingTray = false
            }
        }.id(UUID())
    }
}

struct listItemView: View {
    
    @Binding var openTrays: [Bool]
    @Binding var draggingTray: Bool
    let displayIndex: Int
    let oneListItem: listItem

    var body: some View {
        if oneListItem.isTray {
            
            let oneTray = oneListItem.trayData!
            let trayOpen = self.openTrays[oneTray.trayID - 1]
            HStack {
                Text("\(displayIndex)")
                    .font(Font.subheadline)
                Text(oneTray.name)
                    .bold()
                Spacer()
                    .frame(width: 30)
                Text("ID: \(oneTray.trayID)")
                    .font(Font.footnote)
                Spacer()
                Button {
                    self.draggingTray = false
                    self.openTrays[oneTray.trayID - 1].toggle()
                } label: {
                    Image(systemName: "chevron.right")
                        .rotationEffect(Angle(degrees: trayOpen && !draggingTray ? 90 : 0))
                }
            }
        } else {
            let oneCard = oneListItem.cardData!
            let cardVisible = (self.openTrays[oneCard.inheritID - 1] && !self.draggingTray)
            if cardVisible {
                HStack {
                    Text("\(displayIndex)")
                        .font(Font.subheadline)
                    Spacer()
                        .frame(width:15)
                    Text(oneCard.name)
                    Spacer()
                        .frame(width: 30)
                    Text("inherit ID: \(oneCard.inheritID)")
                        .font(Font.footnote)
                }
            }
        }

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
