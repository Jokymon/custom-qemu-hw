#include "mainwindow.h"
#include "ui_mainwindow.h"
#include <QMessageBox>

MainWindow::MainWindow(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::MainWindow),
    tcpserver(nullptr),
    tcpclient(nullptr)
{
    ui->setupUi(this);
}

MainWindow::~MainWindow()
{
    delete ui;
}

void MainWindow::on_about()
{
    QMessageBox::about(this, "About", "GPIO Listener");
}

void MainWindow::on_start()
{
    if (tcpserver)
        return;

    tcpserver = new QTcpServer(this);
    connect(tcpserver, SIGNAL(newConnection()), this, SLOT(on_acceptconnection()));
    tcpserver->listen(QHostAddress::Any, ui->text_port->text().toUInt()); // TODO: port from dialog box

    ui->text_port->setEnabled(false);
    ui->button_start->setEnabled(false);
    ui->button_stop->setEnabled(true);
}

void MainWindow::on_stop()
{
    if (!tcpserver)
        return;

    if (tcpclient) {
        disconnect(tcpclient, SIGNAL(readyRead()), this, SLOT(on_clientread()));
        disconnect(tcpclient, SIGNAL(disconnected()), this, SLOT(on_disconnected()));
        tcpclient->close();
        delete tcpclient;
        tcpclient = nullptr;
    }

    tcpserver->close();
    delete tcpserver;
    tcpserver = nullptr;

    ui->text_port->setEnabled(true);
    ui->button_start->setEnabled(true);
    ui->button_stop->setEnabled(false);
}

void MainWindow::on_acceptconnection()
{
    QTcpSocket * sock = tcpserver->nextPendingConnection();

    if (tcpclient) {
        delete sock;
        return;
    }
    tcpclient = sock;
    connect(tcpclient, SIGNAL(readyRead()), this, SLOT(on_clientread()));
    connect(tcpclient, SIGNAL(disconnected()), this, SLOT(on_disconnected()));
    ui->label_status->setText(QString("connected"));
}

void MainWindow::on_clientread()
{
    typedef enum { CMD_INVALID = 0, CMD_WRITE = 1, CMD_READ = 2, CMD_RESULT = 3 } cmd_t;

    typedef struct {
        uint8_t cmd;
        uint8_t data;
    } msg_t;

    msg_t msg;

    tcpclient->read(reinterpret_cast<char *>(&msg), sizeof(msg));
    switch (msg.cmd) {
        case CMD_WRITE:
            ui->label_gpios->setText(QString("0x%1").arg(msg.data, 2, 16));
            update_checkboxes(msg.data);
            break;

        default:
            break;
    }
}

void MainWindow::on_disconnected()
{
    ui->label_status->setText(QString("disconnected"));
}

void MainWindow::update_checkboxes(uint8_t value)
{
    if (value & 0x80) {
        ui->chk128->setChecked(true);
    } else {
        ui->chk128->setChecked(false);
    }

    if (value & 0x40) {
        ui->chk64->setChecked(true);
    } else {
        ui->chk64->setChecked(false);
    }

    if (value & 0x20) {
        ui->chk32->setChecked(true);
    } else {
        ui->chk32->setChecked(false);
    }

    if (value & 0x10) {
        ui->chk16->setChecked(true);
    } else {
        ui->chk16->setChecked(false);
    }

    if (value & 0x08) {
        ui->chk8->setChecked(true);
    } else {
        ui->chk8->setChecked(false);
    }

    if (value & 0x04) {
        ui->chk4->setChecked(true);
    } else {
        ui->chk4->setChecked(false);
    }

    if (value & 0x02) {
        ui->chk2->setChecked(true);
    } else {
        ui->chk2->setChecked(false);
    }

    if (value & 0x01) {
        ui->chk1->setChecked(true);
    } else {
        ui->chk1->setChecked(false);
    }

}
