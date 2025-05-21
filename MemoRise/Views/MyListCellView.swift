//
//  MyListCellView.swift
//  MemoRise
//
//  Created by Deepanshu Bajaj on 21/05/25.
//

import SwiftUI

struct MyListCellView: View {
    let myList: MyList
    var showChevron: Bool = true
    
    var body: some View {
        HStack {
            Image(systemName: "line.3.horizontal.circle.fill")
                .foregroundColor(Color(myList.color))
            Text(myList.name)
            Spacer()
            if showChevron {
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .opacity(0.4)
                    .padding([.trailing], 10)
            }
        }
    }
}

struct MyListCellView_Previews: PreviewProvider {
    static var previews: some View {
        MyListCellView(myList: PreviewData.myList)
    }
}
