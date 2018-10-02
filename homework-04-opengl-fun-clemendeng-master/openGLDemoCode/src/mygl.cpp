#include "mygl.h"
#include <la.h>

#include <iostream>
#include <QApplication>
#include <QKeyEvent>


MyGL::MyGL(QWidget *parent)
    : OpenGLContext(parent)
{
    setFocusPolicy(Qt::StrongFocus);
}

MyGL::~MyGL()
{
    makeCurrent();

    glDeleteVertexArrays(1, &vao);
}

void MyGL::initializeGL()
{
    // Create an OpenGL context using Qt's QOpenGLFunctions_3_2_Core class
    // If you were programming in a non-Qt context you might use GLEW (GL Extension Wrangler)instead
    initializeOpenGLFunctions();
    // Print out some information about the current OpenGL context
    debugContextVersion();

    // Set a few settings/modes in OpenGL rendering
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_LINE_SMOOTH);
    glEnable(GL_POLYGON_SMOOTH);
    glHint(GL_LINE_SMOOTH_HINT, GL_NICEST);
    glHint(GL_POLYGON_SMOOTH_HINT, GL_NICEST);
    // Set the size with which points should be rendered
    glPointSize(5);
    // Set the color with which the screen is filled at the start of each render call.
    glClearColor(0.5, 0.5, 0.5, 1);

    printGLErrorLog();

    // Create a Vertex Attribute Object
    glGenVertexArrays(1, &vao);

    // Create VBO data for a square
    glGenBuffers(1, &(this->bufPos));
    glGenBuffers(1, &(this->bufCol));
    glGenBuffers(1, &(this->bufIdx));
    // Our array of position data stored as individual floats,
    // where every four floats is a position in 3D homogeneous coordinates
    std::array<float, 16> positions = {  0.5f,  0.5f, 0.999f, 1.0f,
                                        -0.5f,  0.5f, 0.999f, 1.0f,
                                        -0.5f, -0.5f, 0.999f, 1.0f,
                                         0.5f, -0.5f, 0.999f, 1.0f };
    // Our array of color data stored as vec3s, which are really
    // just sets of three floats each, and at the byte level are
    // no different than a collection of individual floats
    std::array<glm::vec3, 4> colors = { glm::vec3(1.f, 1.f, 0.f),
                                        glm::vec3(0.f, 1.f, 0.f),
                                        glm::vec3(0.f, 0.f, 0.f),
                                        glm::vec3(1.f, 0.f, 0.f) };

    // Send our position and color data to the GPU
    // Need to set bufPos as the "active" VBO so when we invoke
    // glBufferData the floats are sent to that VBO on the GPU
    // Check out https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/glBindBuffer.xhtml
    // for all the different kinds of buffers you can have, defined by the first input
    // to glBindBuffer.
    glBindBuffer(GL_ARRAY_BUFFER, bufPos);

    // Check out https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/glBufferData.xhtml
    // for information on how the last input to this function works
    //           Buffer type      How much data       Where to get data   Hint to GPU as to how data will be used
    glBufferData(GL_ARRAY_BUFFER, 16 * sizeof(float), positions.data(), GL_STATIC_DRAW);

    // Set up color data
    glBindBuffer(GL_ARRAY_BUFFER, bufCol);
    glBufferData(GL_ARRAY_BUFFER, 4 * sizeof(glm::vec3), colors.data(), GL_STATIC_DRAW);

    // Set up our index buffer as well
    std::array<GLuint, 6> indices = {0, 1, 2, 0, 2, 3};
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, bufIdx);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, 6 * sizeof(GLuint), indices.data(), GL_STATIC_DRAW);

    // Need to set up our shader program
    vertShader = glCreateShader(GL_VERTEX_SHADER);
    fragShader = glCreateShader(GL_FRAGMENT_SHADER);
    shaderProgram = glCreateProgram();

    // Get the body of text stored in our two .glsl files
    QString qVertSource = qTextFileRead(":/glsl/flat.vert.glsl");
    QString qFragSource = qTextFileRead(":/glsl/flat.frag.glsl");
    char* vertSource = new char[qVertSource.size()+1];
    strcpy(vertSource, qVertSource.toStdString().c_str());
    char* fragSource = new char[qFragSource.size()+1];
    strcpy(fragSource, qFragSource.toStdString().c_str());

    // Send the shader text to OpenGL and store it in the shaders
    // specified by the handles vertShader and fragShader
    glShaderSource(vertShader, 1, &vertSource, 0);
    glShaderSource(fragShader, 1, &fragSource, 0);
    // Tell OpenGL to compile the shader text stored above
    glCompileShader(vertShader);
    glCompileShader(fragShader);
    // Check if everything compiled OK
    GLint compiled;
    glGetShaderiv(vertShader, GL_COMPILE_STATUS, &compiled);
    if (!compiled) { printShaderInfoLog(vertShader); }
    glGetShaderiv(fragShader, GL_COMPILE_STATUS, &compiled);
    if (!compiled) { printShaderInfoLog(fragShader); }

    // Tell shaderProgram that it manages these particular vertex and fragment shaders
    glAttachShader(shaderProgram, vertShader);
    glAttachShader(shaderProgram, fragShader);
    glLinkProgram(shaderProgram);

    // Check for linking success
    GLint linked;
    glGetProgramiv(shaderProgram, GL_LINK_STATUS, &linked);
    if (!linked) { printLinkInfoLog(shaderProgram); }

    // Get the handles to the variables stored in our shaders
    attrPos = glGetAttribLocation(shaderProgram, "vs_Pos");
    attrCol = glGetAttribLocation(shaderProgram, "vs_Col");

    unifTime = glGetUniformLocation(shaderProgram, "u_Time");

    // The rest of the rendering process occurs in paintGL below.

    // We have to have a VAO bound in OpenGL 3.2 Core. But if we're not
    // using multiple VAOs, we can just bind one once.
    glBindVertexArray(vao);
}

void MyGL::resizeGL(int w, int h)
{
    printGLErrorLog();
}

//This function is called by Qt any time your GL window is supposed to update
//For example, when the function updateGL is called, paintGL is called implicitly.
void MyGL::paintGL()
{
    // Clear the screen so that we only see newly drawn images
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    // Tell the GPU that we want this particular shader program to
    // render our geometry
    glUseProgram(shaderProgram);

    // Update the time uniform variable in our shader
    glUniform1i(unifTime, timeCounter++);

    // Associate vs_Pos (the handle of which is attrPos) with our VBO of position data
    glEnableVertexAttribArray(attrPos);
    glBindBuffer(GL_ARRAY_BUFFER, bufPos);
    glVertexAttribPointer(attrPos, 4, GL_FLOAT, false, 0, static_cast<char*>(0));

    glEnableVertexAttribArray(attrCol);
    glBindBuffer(GL_ARRAY_BUFFER, bufCol);
    glVertexAttribPointer(attrCol, 3, GL_FLOAT, false, 0, static_cast<char*>(0));

    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, bufIdx);
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);

    glDisableVertexAttribArray(bufPos);
    glDisableVertexAttribArray(bufCol);

    printGLErrorLog();
}

void MyGL::keyPressEvent(QKeyEvent *e)
{
    // http://doc.qt.io/qt-5/qt.html#Key-enum
    switch(e->key())
    {
    case(Qt::Key_Escape):
        QApplication::quit();
        break;
    }
}

QString MyGL::qTextFileRead(const char *fileName)
{
    QString text;
    QFile file(fileName);
    if (file.open(QFile::ReadOnly))
    {
        QTextStream in(&file);
        text = in.readAll();
        text.append('\0');
    }
    return text;
}
