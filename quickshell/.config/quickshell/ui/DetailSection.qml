import QtQuick

// Sekcja okna szczegółów: mały nagłówek i karty pod nim.
Column {
    id: root
    default property alias content: body.data
    property string title: ""

    spacing: Theme.spacing + 3

    Text {
        visible: root.title !== ""
        text: root.title.toUpperCase()
        color: Theme.muted
        font.pixelSize: Theme.sectionSize
        font.bold: true
        font.letterSpacing: 1
    }

    Column {
        id: body
        width: root.width
        spacing: Theme.cardSpacing
    }
}
