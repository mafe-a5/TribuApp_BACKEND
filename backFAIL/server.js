const express = require('express');
const sqlite3 = require('sqlite3').verbose();
const path = require('path');
const app = express();
const PORT = 3000;

const dbPath = path.resolve(__dirname, 'Tribu.db');
const db = new sqlite3.Database(dbPath, (err) => {
    if (err) {
        console.error("Error al conectar con la base de datos:", err.message);
    } else {
        console.log("Conectado a la base de datos SQLite");
    }
});

app.use(express.json());

// ENDPOINTS
// usuarios general
app.get('/usuarios', (req, res) => {
    const sql = 'SELECT * FROM usuarios';
    db.all(sql, [], (err, rows) => {
        if (err) {
            res.status(400).json({ "error": err.message });
            return;
        }
        res.json({
            "message": "success",
            "data": rows
        });
    });
});

// GET - Obtener el perfil de un usuario específico
app.get('/usuarios/:id', (req, res) => {
    const sql = 'SELECT * FROM usuarios WHERE id = ?';
    const params = [req.params.id];
    db.get(sql, params, (err, row) => {
        if (err) {
            res.status(400).json({ "error": err.message });
            return;
        }
        res.json({
            "message": "success",
            "data": row
        });
    });
});

// PUT - Actualizar el perfil de un usuario
app.put('/usuarios/:id', (req, res) => {
    console.log(req.body); // Verifica los datos que se reciben en req.body
    const {nombre, celular, foto} = req.body;
    const sql = 'UPDATE usuarios SET nombre = ?, celular = ?, foto = ? WHERE id = ?';
    const params = [nombre, celular, foto, req.params.id];
    db.run(sql, params, function (err) {
        if (err) {
            res.status(400).json({ "error": err.message });
            return;
        }
        res.json({
            "message": "success",
            "changes": this.changes
        });
    });
});

// DELETE - Eliminar un usuario
app.delete('/usuarios/:id', (req, res) => {
    const sql = 'DELETE FROM usuarios WHERE id = ?';
    const params = [req.params.id];
    db.run(sql, params, function (err) {
        if (err) {
            res.status(400).json({ "error": err.message });
            return;
        }
        res.json({
            "message": "deleted",
            "changes": this.changes
        });
    });
});

// PUT - Actualizar solo la foto de perfil
app.put('/usuarios/:id/foto', (req, res) => {
    const { foto } = req.body;
    const sql = 'UPDATE usuarios SET foto = ? WHERE id = ?';
    const params = [foto, req.params.id];
    db.run(sql, params, function (err) {
        if (err) {
            res.status(400).json({ "error": err.message });
            return;
        }
        res.json({
            "message": "Profile photo updated successfully",
            "changes": this.changes
        });
    });
});

// GET - Obtener todos los cursos
app.get('/cursos', (req, res) => {
    const sql = 'SELECT * FROM cursos';
    db.all(sql, [], (err, rows) => {
        if (err) {
            res.status(400).json({ "error": err.message });
            return;
        }
        res.json({
            "message": "success",
            "data": rows
        });
    });
});

// GET - Obtener un curso por ID
app.get('/cursos/:id', (req, res) => {
    const sql = 'SELECT * FROM cursos WHERE id = ?';
    const params = [req.params.id];
    db.get(sql, params, (err, row) => {
        if (err) {
            res.status(400).json({ "error": err.message });
            return;
        }
        res.json({
            "message": "success",
            "data": row
        });
    });
});

// POST - Crear un nuevo curso
app.post('/cursos', (req, res) => {
    const { nombre, nivel_id } = req.body;
    const sql = 'INSERT INTO cursos (nombre, nivel_id) VALUES (?, ?)';
    const params = [nombre, nivel_id];
    db.run(sql, params, function(err) {
        if (err) {
            res.status(400).json({ "error": err.message });
            return;
        }
        res.json({
            "message": "Curso creado con éxito",
            "data": { id: this.lastID }
        });
    });
});

// PUT - Actualizar un curso por ID
app.put('/cursos/:id', (req, res) => {
    const { nombre, nivel_id } = req.body;
    const sql = 'UPDATE cursos SET nombre = ?, nivel_id = ? WHERE id = ?';
    const params = [nombre, nivel_id, req.params.id];
    db.run(sql, params, function(err) {
        if (err) {
            res.status(400).json({ "error": err.message });
            return;
        }
        res.json({
            "message": "Curso actualizado con éxito",
            "changes": this.changes
        });
    });
});

// DELETE - Eliminar un curso por ID
app.delete('/cursos/:id', (req, res) => {
    const sql = 'DELETE FROM cursos WHERE id = ?';
    const params = [req.params.id];
    db.run(sql, params, function(err) {
        if (err) {
            res.status(400).json({ "error": err.message });
            return;
        }
        res.json({
            "message": "Curso eliminado",
            "changes": this.changes
        });
    });
});

// GET - Obtener cursos por nivel
app.get('/cursos/nivel/:nivel_id', (req, res) => {
    const sql = 'SELECT * FROM cursos WHERE nivel_id = ?';
    const params = [req.params.nivel_id];
    db.all(sql, params, (err, rows) => {
        if (err) {
            res.status(400).json({ "error": err.message });
            return;
        }
        res.json({
            "message": "success",
            "data": rows
        });
    });
});

// GET - Obtener profesores de un curso específico
app.get('/cursos/:id/profesores', (req, res) => {
    const sql = `
        SELECT profesores.* FROM profesores
        JOIN curso_profesor ON profesores.id = curso_profesor.profesor_id
        WHERE curso_profesor.curso_id = ?
    `;
    const params = [req.params.id];
    db.all(sql, params, (err, rows) => {
        if (err) {
            res.status(400).json({ "error": err.message });
            return;
        }
        res.json({
            "message": "success",
            "data": rows
        });
    });
});

// GET - Obtener todos los niveles
app.get('/niveles', (req, res) => {
    const sql = 'SELECT * FROM niveles';
    db.all(sql, [], (err, rows) => {
        if (err) {
            res.status(400).json({ "error": err.message });
            return;
        }
        res.json({
            "message": "success",
            "data": rows
        });
    });
});

// POST - Asignar un profesor a un curso
app.post('/cursos/:id/asignar-profesor', (req, res) => {
    const { profesor_id } = req.body;
    const sql = 'INSERT INTO curso_profesor (curso_id, profesor_id) VALUES (?, ?)';
    const params = [req.params.id, profesor_id];
    db.run(sql, params, function(err) {
        if (err) {
            res.status(400).json({ "error": err.message });
            return;
        }
        res.json({
            "message": "Profesor asignado al curso con éxito",
            "data": { curso_id: req.params.id, profesor_id }
        });
    });
});

// DELETE - Eliminar asignación de profesor de un curso
app.delete('/cursos/:id/profesores/:profesor_id', (req, res) => {
    const sql = 'DELETE FROM curso_profesor WHERE curso_id = ? AND profesor_id = ?';
    const params = [req.params.id, req.params.profesor_id];
    db.run(sql, params, function(err) {
        if (err) {
            res.status(400).json({ "error": err.message });
            return;
        }
        res.json({
            "message": "Profesor desasignado del curso",
            "changes": this.changes
        });
    });
});

// POST - Subir material para el curso
app.post('/cursos/:curso_id/materiales', (req, res) => {
    const { nombre, tipo, enlace } = req.body;
    const fecha_subida = new Date().toISOString().split('T')[0]; 
    const sql = 'INSERT INTO materiales (nombre, tipo, fecha_subida, enlace, post_id) VALUES (?, ?, ?, ?, ?)';
    const params = [nombre, tipo, fecha_subida, enlace, req.params.curso_id];
    db.run(sql, params, function(err) {
        if (err) {
            res.status(400).json({ "error": err.message });
            return;
        }
        res.json({
            "message": "Material subido con éxito",
            "data": { id: this.lastID }
        });
    });
});


// Iniciar el servidor
app.listen(PORT, () => {
    console.log(`Servidor corriendo en http://localhost:${PORT}`);
});