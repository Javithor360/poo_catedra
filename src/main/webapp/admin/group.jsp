<%@ page import="com.catedra.catedrapoo.beans.GroupBean" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="com.catedra.catedrapoo.beans.UserBean" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    System.out.println(request.getAttribute("group"));
    System.out.println(request.getAttribute("miembros"));
    System.out.println(request.getAttribute("usuarios"));

    GroupBean group = (GroupBean) request.getAttribute("group");

    if (group == null) {
        response.sendRedirect("/admin/groups.jsp");
        return;
    }

    HashMap<Integer, UserBean> members = (HashMap<Integer, UserBean>) request.getAttribute("miembros");
    HashMap<Integer, UserBean> users = (HashMap<Integer, UserBean>) request.getAttribute("usuarios");
%>

<html>
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="../assets/css/bootstrap.min.css" rel="stylesheet">
    <script src="../assets/js/bootstrap.min.js"></script>
    <title>Admin - Gestión de grupos</title>
</head>
<body>

<jsp:include page="../navbar.jsp"/>

<main class="container mt-3">
    <h1 class="text-center mb-4">Grupo N° <%= group.getId() + " " + group.getName() %>
    </h1>
    <h2><%= group.getName().split(" ")[0] %>
    </h2>
    <div class="text-center mb-2">Asigna o remueve integrantes del grupo</div>
    <hr/>
    <div class="row">
        <div class="col">
            <h4 class="">Pertenecientes al Grupo</h4>
            <ul class="list-group" id="groupMembers">
                <%
                    for (UserBean miembro : members.values()) {
                %>
                <li class="list-group-item" data-id="<%= miembro.getId()%>">
                    <%= miembro.getName() %>
                </li>
                <%
                    }
                %>
            </ul>
        </div>

        <div class="d-flex align-items-center flex-column justify-content-center display-1">
            <span>➡️</span>
            <span>⬅️</span>
        </div>

        <div class="col">
            <h4 class="">Usuarios Disponibles</h4>
            <ul class="list-group" id="availableUsers">
                <%
                    if (users.isEmpty()) {
                %>
                <li class="list-group-item">No hay usuarios disponibles</li>
                <%
                } else {
                    for (UserBean usuario : users.values()) {
                %>
                <li class="list-group-item" data-id="<%= usuario.getId()%>">
                    <%= usuario.getName() %>
                </li>
                <%
                        }
                    }
                %>
            </ul>
        </div>
    </div>

    <a href="groups.jsp" class="btn btn-secondary mt-3">Volver</a>
</main>
</body>

<script>
    (() => {
        // Elementos de la lista de usuarios disponibles del DOM
        const availablesList = document.getElementById('availableUsers');
        const groupMembersList = document.getElementById('groupMembers');

        // Objetos Globales
        let groupMembers = [
            <%
                if (!members.isEmpty()) {
                    int count = 0;
                    for (UserBean member : members.values()) {
                        if (count > 0) {
            %>
            ,
            <% } %>
            {
                id: <%= member.getId() %>,
                name: "<%= member.getName() %>"
            }
            <%
                        count++;
                    }
                }
            %>
        ];

        let availableGroup = [
            <%
                  if (!users.isEmpty()) {
                      int count = 0;
                      for (UserBean user : users.values()) {
                          if (count > 0) {
            %>
            ,
            <% } %>
            {
                id: <%= user.getId() %>,
                name: "<%= user.getName() %>"
            }
            <%
                        count++;
                    }
                }
            %>
        ];

        console.log(groupMembers);
        console.log(availableGroup);

        availablesList.addEventListener('click', (e) => {
            handleListClick(e, availableGroup, groupMembers, availablesList, groupMembersList);
        });

        groupMembersList.addEventListener('click', (e) => {
            handleListClick(e, groupMembers, availableGroup, groupMembersList, availablesList);
        });

        function handleListClick(e, fromList, toList, fromElement, toElement) {
            let {id} = e.target.dataset;

            if (id) {

                // Válidar que el grupo de miembros no esté vacío
                if (fromList === groupMembers && fromList.length === 1) {
                    alert('El Grupo debe mantener al menos un integrante');
                    return;
                }

                moveItem(+id, fromList, toList);
                clearAndReprintList(fromList, fromElement);
                clearAndReprintList(toList, toElement);
            }
        }

        function moveItem(id, fromList, toList) {
            const index = fromList.findIndex(item => item.id === id); // Encontrar el índice del objeto en la lista
            if(index !== -1) {
                const [itemMoved] = fromList.splice(index, 1); // Extraer el elemento como objeto

                // Determinar el tipo de acción según lista
                const action = (fromList === groupMembers) ? 'delete_user_from_group' : 'add_user_to_group';
                const groupId = <%= group.getId() %>;

                updateUserGroup(itemMoved.id, groupId, action);
                toList.push(itemMoved); // Agregar el objeto a la lista
            }
        }

        // Limpiar y reimprimir una lista en el HTML
        function clearAndReprintList(list, element) {
            clearHTML(element);

            if (list.length === 0 && element === availableUsers) {
                let li = document.createElement('li');
                li.classList.add('list-group-item');
                li.textContent = 'No hay usuarios disponibles';
                element.appendChild(li);
            } else {
                list.forEach(item => printListItem(item, element));
            }
        }

        // Limpiar elementos del HTML
        function clearHTML(element) {
            while (element.firstChild) {
                element.removeChild(element.firstChild);
            }
        }

        // Imprimir un item en la lista del HTML
        function printListItem(item, element) {
            const listItem = document.createElement('li');
            listItem.classList.add('list-group-item');
            listItem.dataset.id = item.id; // Usar propiedad del objeto
            listItem.innerText = item.name; // Usar propiedad del objeto
            element.appendChild(listItem);
        }

        function updateUserGroup(userId, groupId, action) {
            fetch(`/adm`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    userId: userId,
                    groupId: groupId,
                    action: action
                })
            })
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        alert('Usuario actualizado con éxito');
                    } else {
                        alert('Error al actualizar usuario: ' + data.error);
                    }
                })
                .catch(error => {
                    alert('Error al actualizar usuario: ' + error);
                });
        }
    })()
</script>

</html>
