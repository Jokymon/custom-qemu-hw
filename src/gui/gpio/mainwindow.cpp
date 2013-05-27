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
            break;

        default:
            break;
    }
}

void MainWindow::on_disconnected()
{
    ui->label_status->setText(QString("disconnected"));
}
