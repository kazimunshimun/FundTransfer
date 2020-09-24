//
//  ContentView.swift
//  FundTransferApp
//
//  Created by Anik on 26/8/20.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var dragDrop = UserDragDrop()
    @Namespace private var viewSpace
    var body: some View {
        ZStack {
            VStack {
                TopBarView()
                
                Spacer()
                
                CardView()
                    .padding(.top, 30)

                RecentlyTradedView(dragDrop: dragDrop, viewSpace: viewSpace)
                    .padding(.top, 20)

            }
            .padding(.horizontal)
            .padding(.top, 80)
            
            if dragDrop.dragDropConfig.isDroppedOnPayment {
                //need to show the payment view lets do with matched geometry animation
                PaymentView(viewSpace: viewSpace, dragDrop: dragDrop)
            }
            
            if dragDrop.dragDropConfig.isDroppedOnCollect {
                //need to show the collect view
            }
        }
        .background(Color.background)
        .edgesIgnoringSafeArea(.all)
    }
}

struct PaymentView: View {
    public var viewSpace: Namespace.ID
    @ObservedObject var dragDrop: UserDragDrop
    @ObservedObject var input =  PaymentInput()
    
    @State var config = PaymentViewConfig()
    
    var body: some View {
        ZStack {
            Rectangle()
                .onTapGesture {
                    withAnimation {
                        dragDrop.dragDropConfig.isDroppedOnPayment = false
                    }
                }
            
            VStack {
                Spacer(minLength: config.topPadding/2)
                
                CreditCardView(showCreditCard: $config.showCreditCard)
                
                Spacer(minLength: config.topPadding/2)
                
                RoundedRectangle(cornerRadius: 25.0)
                    .fill(Color.background)
                    .matchedGeometryEffect(id: "ViewID", in: viewSpace)
            }
            
            
            VStack(spacing: 20) {
                Spacer(minLength: config.showCreditCard ? 290 : 120)
                
                UserViewForDrag(user: dragDrop.pickedUser, width: 100)
                    .scaleEffect(config.startAnimation ? 1.0 : 0.0)
                
                Text("Transfer to ") + Text("\(dragDrop.pickedUser.name)").fontWeight(.heavy)
                
                HStack {
                    Text("$")
                    Text(input.amount)
                    RoundedRectangle(cornerRadius: 2)
                        .frame(width: 3, height: 45)
                        .opacity(config.blink ? 0.0 : 1.0)
                        .opacity(config.showCreditCard ? 0.0 : 1.0)
                        .onAppear {
                            withAnimation(Animation.linear(duration: 0.7).repeatForever()) {
                                config.blink.toggle()
                            }
                        }
                }
                .font(.system(size: 48, weight: .black))
                
                Spacer()
                
                PaymentCompletionView(config: $config, dragDrop: dragDrop)
                
                DescriptionView()
                    .opacity(config.showCreditCard ? 0.0 : 1.0)
                    //.frame(height: config.showCreditCard ? 0.0 : 60.0)
                
                HStack {
                    NumberPadView(input: input)
                    
                    PaymentActionView(input: input, config: $config)
                }
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 40))
                .padding(.horizontal)
                .padding(.bottom, 34)
                .offset(y: config.startAnimation ? 0.0 : 300)
                .opacity(config.showCreditCard ? 0.0 : 1.0)
                .frame(height: config.showCreditCard ? 0.0 : 280.0)
            }
        }
        .onAppear {
            withAnimation(Animation.linear(duration: 0.7)) {
                config.startAnimation = true
              //  config.showCreditCard = true
              //  config.topPadding = 200
            }
        }
    }
}

struct DescriptionView: View {
    var body: some View {
        HStack {
            HStack {
                Text("🇺🇸")
                    .font(.system(size: 60))
                    .fixedSize()
                    .frame(width: 30, height: 30)
                    .cornerRadius(15)
                Text("USD")
                    .font(.system(size: 20))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white)
            .cornerRadius(30)
            
            TextField("Say something", text: .constant(""))
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(Color.white)
                .cornerRadius(30)
        }
        .padding(.horizontal)
    }
}

struct NumberPadView: View {
    let numbers = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        ["0", "", "."]
    ]
    @ObservedObject var input:  PaymentInput
    var body: some View {
        VStack {
            ForEach(numbers, id: \.self) { row in
                HStack {
                    ForEach(row, id: \.self) { number in
                        Button(action: {
                            input.handleNumbers(number: number)
                        }, label: {
                            Text(number)
                                .padding(12)
                                .fixedSize()
                                .frame(width: 70)
                                .foregroundColor(.black)
                        })
                    }
                }
            }
        }
        .font(.system(size: 28, weight: .bold))
        .padding(.leading, 8)
    }
}

struct PaymentActionView: View {
    @ObservedObject var input:  PaymentInput
    @Binding var config: PaymentViewConfig
    
    var body: some View {
        VStack {
            Button(action: {
                input.handleBackspace()
            }, label: {
                Image(systemName: "delete.left")
                    .font(.system(size: 24))
                    .padding(16)
                    .fixedSize()
                    .frame(width: 70)
            })
            
            
            Button(action: {
                withAnimation(.linear(duration: 0.7)) {
                    config.showCreditCard = true
                }
            }, label: {
                ZStack {
                    Rectangle()
                        .fill()
                        .frame(height: 200)
                    Text("SEND")
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                }
            })
            
        }
        .foregroundColor(.black)
    }
}

struct CreditCardView: View {
    @Binding var showCreditCard: Bool
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.cardLinear)
                
            
            VStack(spacing: 16) {
                HStack {
                    Text("Credit Card")
                        .bold()
                    Spacer()
                    
                    Image(systemName: "wave.3.right")
                        .font(.system(size: 30))
                }
                
                HStack(alignment: .firstTextBaseline) {
                    Image(systemName: "simcard.fill")
                        .font(.system(size: 40))
                        .rotationEffect(.degrees(90))
                    
                    Spacer()
                    
                    Text("9456 8944 9456 8944")
                        .bold()
                }
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("Card Holder")
                        Text("Dimest")
                            .bold()
                    }
                    .font(.system(size: 12))
                    
                    Spacer()
                    
                    Text("VISA")
                        .italic()
                        .bold()
                        .font(.system(size: 30))
                }
            }
            .padding(.horizontal)
            .foregroundColor(.white)
        }
        .frame(width: 300, height: showCreditCard ? 170 : 0.0)
        .opacity(showCreditCard ? 1.0 : 0.0)
    }
}

struct PaymentCompletionView: View {
    @Binding var config: PaymentViewConfig
    @ObservedObject var dragDrop: UserDragDrop
    var body: some View {
        ZStack {
            Button(action: {
                config.faceIDSuccess = true
                withAnimation(.linear(duration: 1.5)) {
                    config.startRotationAnimation = true
                }
            }, label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(lineWidth: 4)
                    
                    Image(systemName: "faceid")
                        .font(.system(size: 102))
                        .opacity(config.faceIDSuccess ? 0.0 : 1.0)
                }
                .rotationEffect(config.startRotationAnimation ? .degrees(240.0) : .degrees(0.0))
                .opacity(config.startRotationAnimation ? 0.0 : 1.0)
                .foregroundColor(.black)
            })
            
            
            Button(action: {
                withAnimation {
                    dragDrop.dragDropConfig.isDroppedOnPayment = false
                }
            }, label: {
                ZStack {
                    Circle()
                        .stroke(style: StrokeStyle(lineWidth: 4, lineCap: .round, dash: [2, 34]))
                        .scaleEffect(config.startRotationAnimation ? 1.4 : 1.2)
                        .rotationEffect(config.startRotationAnimation ? .degrees(0.0) : .degrees(-360.0))
                        .opacity(config.startRotationAnimation ? 0.0 : 1.0)
                    
                    Circle()
                        .stroke(lineWidth: 4)
                    
                    CheckmarkShape()
                        .trim(from: 0.0, to: config.startRotationAnimation ? 1.0 : 0.0)
                        .stroke(style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                }
                .foregroundColor(.black)
            })
            .opacity(config.startRotationAnimation ? 1.0 : 0.0)
            
        }
        .frame(width: config.showCreditCard ? 100 : 0.0,
               height: config.showCreditCard ? 100 : 0.0)
        .opacity(config.showCreditCard ? 1.0 : 0.0)
    }
}

struct CheckmarkShape: Shape {
    func path(in rect: CGRect) -> Path {
        return Path { path in
            path.move(to: CGPoint(x: 25, y: 50))
            path.addLine(to: CGPoint(x: 25, y: 50))
            path.addLine(to: CGPoint(x: 40, y: 65))
            path.addLine(to: CGPoint(x: 70, y: 35))
        }
    }
}

class PaymentInput: ObservableObject {
    @Published var amount = ""
    
    func handleNumbers(number: String) {
        //restrict digit count to 7
        if amount.count < 7 {
            if number != "." {
                amount.append(number)
            } else {
                //check if . already in the string
                if !amount.contains(".") {
                    amount.append(number)
                }
            }
        }
    }
    
    func handleBackspace() {
        if amount.count > 0 {
            amount.removeLast()
        }
    }
}

struct PaymentViewConfig {
    var blink = false
    var startAnimation = false
    var showCreditCard = false
    var faceIDSuccess = false
    var startRotationAnimation = false
    var topPadding: CGFloat = 180
}

struct TopBarView: View {
    var body: some View {
        HStack(spacing: 20) {
            Circle()
                .frame(width: 50, height: 50)
            
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 50, height: 50)
                Image(systemName: "bell")
            }
            
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 50, height: 50)
                Image(systemName: "ellipsis")
                    .rotationEffect(.degrees(90))
            }
        }
    }
}

struct CardView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25.0)
                .fill(Color.cardLinear)
                .frame(height: 220)
            
            VStack(alignment: .leading, spacing: 15) {
                HStack(alignment: .top) {
                    Text("Hello, Dimest \nBalance")
                        .font(.system(size: 20, weight: .bold))
                        
                    Spacer()
                    
                    Text("P")
                        .font(.system(size: 30, weight: .heavy))
                        .italic()
                }
                
                Text("$9844.00")
                    .font(.system(size: 30, weight: .heavy))
                
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .frame(height: 50)
                    
                    HStack {
                        Text("Your Transaction")
                            
                        Spacer()
                        
                        Image(systemName: "chevron.down")
                    }
                    .foregroundColor(.black)
                    .padding(.horizontal)
                }
            }
            .padding(.horizontal)
            .foregroundColor(.white)
        }
    }
}

struct MenuSelectionView: View {
    @ObservedObject var dragDrop: UserDragDrop
    public var viewSpace: Namespace.ID
    var body: some View {
        HStack {
            //we need to know the rect positon of this 2 view
            GeometryReader { geo in
                MenuItemView(imageName: "creditcard.fill", title: "Payment", didEntered: dragDrop.dragDropConfig.isEnteredPayment)
                    .matchedGeometryEffect(id: "ViewID", in: viewSpace)
                    .onAppear {
                        dragDrop.paymentViewRect = geo.frame(in: .global)
                    }
            }

            GeometryReader { geo in
                MenuItemView(imageName: "dollarsign.circle", title: "Collect Money", didEntered: dragDrop.dragDropConfig.isEnteredCollect)
                    .onAppear {
                        dragDrop.collectViewRect = geo.frame(in: .global)
                    }
            }
            
        }
        .frame(height: 150)
    }
}

struct MenuItemView: View {
    let imageName: String
    let title: String
    var didEntered: Bool = false
    
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(lineWidth: didEntered ? 2.0 : 0.0) // to show user that drag user entered the menu
                )
            
            VStack(alignment: .leading) {
                ZStack {
                    Circle()
                        .fill(Color.logoLinear)
                        .frame(width: 45, height: 45)
                    Image(systemName: imageName)
                        .foregroundColor(.white)
                }
                
                Text(title)
            }
            .padding(.horizontal)
        }
    }
}

struct RecentlyTradedView: View {
    @ObservedObject var userManager = UserManager()
    @State var isRotating = false
    
    @ObservedObject var dragDrop: UserDragDrop
    
    @State var pickedUserName = "profile_user" // this use we did not use in circle
    
    public var viewSpace: Namespace.ID
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack {
                MenuSelectionView(dragDrop: dragDrop, viewSpace: viewSpace)
                    .padding(.all, 2)
                
                RecentlyTradedTitleView()
                    .padding(.top, 20)
                
                ZStack {
                    RotationPathView(isRotating: $isRotating)
                    
                    ForEach(userManager.userData) { user in
                        UserView(user: user)
                            .rotationEffect(.degrees(isRotating ? 360 : 0))
                            .animation(Animation.linear(duration: 10.0).repeatForever(autoreverses: false))
                            .opacity(userManager.userData[user.id].isDragging ? 0.0 : 1.0)
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged({ value in
                                        if pickedUserName == "profile_user" {
                                            //initial started
                                            pickedUserName = user.imageName
                                            dragDrop.pickedUser = user
                                            dragDrop.shouldScoll = false
                                            dragDrop.dragDropConfig.isDragging = true
                                            userManager.changeUserDraggingValue(index: user.id)
                                        }
                                        
                                        // we need to continuously check the intersection
                                        dragDrop.checkRectEnter(location: value.location)
                                    })
                                    .onEnded({ value in
                                        userManager.changeUserDraggingValue(index: user.id)
                                        dragDrop.checkDrop()
                                        pickedUserName = "profile_user"
                                    })
                            
                            )
                    }
                    
                    // as it is difficult to drag a view which is already moving so we have be little creative, we will create a userview for draggin which is not moving. We need this user view rect position for intersection
                    
                    GeometryReader { geo in
                        UserViewForDrag(user: dragDrop.pickedUser)
                            .offset(x: dragDrop.offsetValue.x - 30,
                                    y: dragDrop.offsetValue.y - 30) // 30 for radius of userView
                            .opacity(dragDrop.dragDropConfig.isDragging ? 1.0 : 0.0)
                            .onAppear {
                                dragDrop.userViewRect = geo.frame(in: .global)
                                dragDrop.dragUserMovingPoint = CGPoint(
                                    x: dragDrop.userViewRect.minX,
                                    y: dragDrop.userViewRect.minY)
                            }
                    }
                    .frame(width: 60, height: 60)
                    
                    
                }
                .padding(.top, 30)
            }
        }
        .onAppear {
            isRotating = true
        }
    }
}

class UserDragDrop: ObservableObject {
    // 3 rect postion i need to know
    var paymentViewRect = CGRect()
    var collectViewRect = CGRect()
    var userViewRect = CGRect()
    
    @Published var dragDropConfig = DragDropConfig()
    
    //when dragging scroll view should stop scrolling
    @Published var shouldScoll = true
    var scrollAxis: Axis.Set {
        return shouldScoll ? .vertical : []
    }
    
    // i need to know which user is dragging
    @Published var pickedUser = Data.data[0] // for initial
    
    // how much drag occur
    @Published var dragUserMovingPoint = CGPoint()
    @Published var offsetValue = CGPoint(x: 0, y: 0)
    
    // next I need 2 function to check if user rect intersect with paymentView rect or collect view rect
    // so drag working now check if we can work drop
    func checkRectEnter(location: CGPoint) {
        offsetValue = location
        dragUserMovingPoint = CGPoint(
            x: userViewRect.minX + offsetValue.x - 30,
            y: userViewRect.minY + offsetValue.y - 30)
        
        let userRect = CGRect(x: dragUserMovingPoint.x, y: dragUserMovingPoint.y, width: 60, height: 60)
        
        if paymentViewRect.intersects(userRect) {
            if (dragDropConfig.isEnteredCollect) { // first checking if user already entered in collect view
                dragDropConfig.isEnteredCollect = false
            }
            
            if !dragDropConfig.isEnteredPayment { // checking if user view already not entered in paymnet view
                dragDropConfig.isEnteredPayment = true
            }
        } else {
            if dragDropConfig.isEnteredPayment {
                dragDropConfig.isEnteredPayment = false
            }
            
            if collectViewRect.intersects(userRect) {
                if !dragDropConfig.isEnteredCollect {
                    dragDropConfig.isEnteredCollect = true
                }
            } else {
                if dragDropConfig.isEnteredCollect {
                    dragDropConfig.isEnteredCollect = false
                }
            }
        }
        
    }
    
    // and if user dropped on either paymentView or collectView
    func checkDrop() {
        shouldScoll = true
        dragDropConfig.isDragging = false
        
        offsetValue = CGPoint(x: 0, y: 0)
        dragUserMovingPoint = CGPoint(x: userViewRect.minX, y: userViewRect.minY)
        
        if dragDropConfig.isEnteredPayment {
            //need to reset the enter payment
            dragDropConfig.isEnteredPayment = false
            //dropped on payment need to do with animation
            withAnimation {
                dragDropConfig.isDroppedOnPayment = true
            }
        }
        
        if dragDropConfig.isEnteredCollect {
            dragDropConfig.isEnteredCollect = false
            //dropped on collect
            withAnimation {
                dragDropConfig.isDroppedOnCollect = true
            }
        }
    }
}

struct DragDropConfig {
    var isEnteredPayment = false
    var isEnteredCollect = false
    
    var isDragging = false
    
    var isDroppedOnPayment = false
    var isDroppedOnCollect = false
}

struct RecentlyTradedTitleView: View {
    var body: some View {
        HStack {
            Text("Recently traded")
                .font(.system(size: 20, weight: .bold))
            
            Spacer()
            
            Image(systemName: "chevron.right")
        }
    }
}

struct RotationPathView: View {
    @Binding var isRotating: Bool
    var body: some View {
        ZStack {
            Circle()
                .stroke(style: StrokeStyle(lineWidth: 1, lineCap: .square, dash: [8]))
                .frame(width: 300, height: 300)
                .rotationEffect(.degrees(isRotating ? 360 : 0))
                
            
            Circle()
                .stroke(style: StrokeStyle(lineWidth: 1, lineCap: .square, dash: [8]))
                .frame(width: 170, height: 170)
                .rotationEffect(.degrees(isRotating ? -360 : 0))
            
            Circle()
                .stroke(style: StrokeStyle(lineWidth: 1, lineCap: .square, dash: [8]))
                .frame(width: 60, height: 60)
                .rotationEffect(.degrees(isRotating ? 360 : 0))
        }
        .animation(Animation.linear(duration: 10.0).repeatForever(autoreverses: false))
        .opacity(0.5)
    }
}

struct UserView: View {
    let user: User
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .frame(width: 60, height: 60)
            
            Image(user.imageName)
        }
        .offset(x: user.id < 3 ? 85 : 150)
        .rotationEffect(.degrees(Double(user.id * 100)))
    }
}

struct UserViewForDrag: View {
    let user: User
    var width: CGFloat = 60
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .frame(width: width, height: width)
            
            Image(user.imageName)
                .resizable()
                .frame(width: width - 10, height: width - 10)
        }
    }
}

struct User: Identifiable {
    let id: Int
    let name: String
    let imageName: String
    var isDragging: Bool = false
}

struct Data {
    static let data = [
        User(id: 0, name: "Alex", imageName: "alex_pp"),
        User(id: 1, name: "Jennifer", imageName: "jennifer_pp"),
        User(id: 2, name: "Lisa", imageName: "lisa_pp"),
        User(id: 3, name: "Mike", imageName: "mike_pp"),
        User(id: 4, name: "Sandra", imageName: "sandra_pp"),
        User(id: 5, name: "Travis", imageName: "travis_pp"),
    ]
}

class UserManager: ObservableObject {
    @Published var userData = Data.data
    
    func changeUserDraggingValue(index: Int) {
        userData[index].isDragging.toggle()
    }
}

extension Color {
    static let background   = Color.init(red: 1, green: 246/255, blue: 1)
    
    static let cardStart    = Color.init(red: 11/255, green: 19/255, blue: 2/255)
    static let cardEnd      = Color.init(red: 48/255, green: 53/255, blue: 27/255)
    
    static let cardLinear   = LinearGradient(
        gradient: Gradient(colors: [cardStart, cardEnd]),
        startPoint: .leading,
        endPoint: .trailing)
    
    static let logoLinear   = LinearGradient(
        gradient: Gradient(colors: [Color.purple.opacity(0.3), Color.black]),
        startPoint: .bottomLeading,
        endPoint: .top)
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
