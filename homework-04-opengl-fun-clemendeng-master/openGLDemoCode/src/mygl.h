#pragma once

#include <openglcontext.h>
#include <utils.h>
#include <shaderprogram.h>
#include <scene/grid.h>
#include <scene/polygon.h>

#include <QOpenGLVertexArrayObject>
#include <QOpenGLShaderProgram>


class MyGL
    : public OpenGLContext
{
private:
    GLuint vao; // A handle for our vertex array object. This will store the VBOs created in our geometry classes.

    GLuint bufPos; // A handle for the vertex buffer object we'll use to store vertex positions.
    GLuint bufCol; // A handle for the vertex buffer object we'll use to store vertex UVs.
    GLuint bufInterleaved; // A handle for the vertex buffer object we can alternatively use to store both positions and UVs.

    GLuint bufIdx; // A handle for the index buffer object we'll use to order our vertices for drawing

    GLuint vertShader; // A handle to our vertex shader
    GLuint fragShader; // A handle to our fragment shader
    GLuint shaderProgram; // A handle to the shader program object on the GPU
                          // that links our vertex and fragment shaders into
                          // the same shader pipeline

    int attrPos; // A handle for the shader variable used to track vertex position
    int attrCol; // A handle for the shader variable used to track vertex color

    int unifTime; // A handle for the shader variable used to track time elapsed

    int timeCounter; // A variable to track the value of time elapsed so we can pass it to the GPU

public:
    explicit MyGL(QWidget *parent = 0);
    ~MyGL();

    void initializeGL();
    void resizeGL(int w, int h);
    void paintGL();

    QString qTextFileRead(const char *fileName);

protected:
    void keyPressEvent(QKeyEvent *e);
};

