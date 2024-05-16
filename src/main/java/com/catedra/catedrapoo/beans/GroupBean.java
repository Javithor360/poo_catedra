package com.catedra.catedrapoo.beans;

public class GroupBean {
    private int id;
    private String name;
    private BasicUserBean boss;
    private AreaBean area;
    private int members_count;

    public GroupBean(int id, String name, BasicUserBean boss, AreaBean area, int members_count) {
        this.id = id;
        this.name = name;
        this.boss = boss;
        this.area = area;
        this.members_count = members_count;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public BasicUserBean getBoss() {
        return boss;
    }

    public void setBoss(BasicUserBean boss) {
        this.boss = boss;
    }

    public AreaBean getArea() {
        return area;
    }

    public void setArea(AreaBean area) {
        this.area = area;
    }

    public int getMembers_count() {
        return members_count;
    }

    public void setMembers_count(int members_count) {
        this.members_count = members_count;
    }
}
